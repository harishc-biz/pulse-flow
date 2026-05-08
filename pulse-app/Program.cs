using Azure.Messaging.ServiceBus;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// Add logging so we can see what's happening in the AKS logs
builder.Logging.AddConsole();

var app = builder.Build();

// 1. FETCH CONFIGURATION FROM ENVIRONMENT VARIABLES
// In AKS, these will be injected from Key Vault.
// Locally, you must set these in your terminal before running.
string connectionString = Environment.GetEnvironmentVariable("ServiceBusConnectionString") 
    ?? throw new Exception("CRITICAL ERROR: Environment Variable 'ServiceBusConnectionString' is missing!");

string queueName = Environment.GetEnvironmentVariable("QueueName") 
    ?? "work-queue"; // Defaults to work-queue if not specified

// 2. INITIALIZE SERVICE BUS CLIENTS
// We do this once at startup to be efficient.
var client = new ServiceBusClient(connectionString);
var sender = client.CreateSender(queueName);

// This list stores results in-memory for your GET endpoint.
// Note: If the pod restarts in AKS, this list will clear.
var processedItems = new List<string>();

// 3. THE API ENDPOINTS

// POST: Enqueue work to Azure Service Bus
app.MapPost("/api/work", async ([FromBody] string message) => 
{
    if (string.IsNullOrEmpty(message)) return Results.BadRequest("Message cannot be empty.");

    app.Logger.LogInformation("Enqueuing message: {msg}", message);

    try 
    {
        var busMessage = new ServiceBusMessage(message);
        await sender.SendMessageAsync(busMessage);
        return Results.Accepted(value: new { Status = "Enqueued", Content = message });
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "Failed to send message to Service Bus.");
        return Results.Problem("Error connecting to Azure Service Bus.");
    }
});

// GET: Return the items processed by the background worker
app.MapGet("/api/work", () => 
{
    return Results.Ok(processedItems);
});

// 4. THE BACKGROUND WORKER
// This runs automatically in the background to "listen" to the queue.
_ = Task.Run(async () => 
{
    var processor = client.CreateProcessor(queueName);

    // This logic runs every time a new message arrives in the queue
    processor.ProcessMessageAsync += async args => 
    {
        string body = args.Message.Body.ToString();
        Console.WriteLine($"[Worker] Processing message from Azure: {body}");

        // Add to our list with a timestamp
        processedItems.Add($"{body}");

        // Tell Azure the message is handled successfully
        await args.CompleteMessageAsync(args.Message);
    };

    // This logic handles errors (like network drops)
    processor.ProcessErrorAsync += args => 
    {
        Console.WriteLine($"[Worker Error] {args.Exception.Message}");
        return Task.CompletedTask;
    };

    app.Logger.LogInformation("Background Processor started. Waiting for messages...");
    await processor.StartProcessingAsync();
});

app.Run();