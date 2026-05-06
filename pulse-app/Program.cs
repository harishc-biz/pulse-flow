using Azure.Messaging.ServiceBus;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// 1. Setup Connection Details
// Paste your string between the quotes
string connectionString = "";
string queueName = "work-queue";

// 2. Initialize the Service Bus Client
var client = new ServiceBusClient(connectionString);
var sender = client.CreateSender(queueName);
var processedItems = new List<string>();

// POST: Enqueue work
// The [FromBody] tells .NET to look at the JSON data, not the URL
app.MapPost("/api/work", async ([FromBody] string message) => 
{
    app.Logger.LogInformation($"Received request to enqueue: {message}");
    
    var busMessage = new ServiceBusMessage(message);
    await sender.SendMessageAsync(busMessage);
    
    return Results.Accepted(value: $"Message: '{message}' sent to Azure!");
});

// GET: View processed work
app.MapGet("/api/work", () => 
{
    return Results.Ok(processedItems);
});

// 3. Background Processor Logic
_ = Task.Run(async () => 
{
    var processor = client.CreateProcessor(queueName);

    processor.ProcessMessageAsync += async args => 
    {
        string body = args.Message.Body.ToString();
        Console.WriteLine($"[Worker] Processing: {body}");
        
        // Simulate some work logic
        processedItems.Add($"{body}");
        
        // Tell Azure the message is done and can be deleted from the queue
        await args.CompleteMessageAsync(args.Message);
    };

    processor.ProcessErrorAsync += args => 
    {
        Console.WriteLine($"[Worker Error] {args.Exception.Message}");
        return Task.CompletedTask;
    };

    await processor.StartProcessingAsync();
});

app.Run();