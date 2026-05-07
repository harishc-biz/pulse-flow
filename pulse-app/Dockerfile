# STAGE 1: Build
# Use the .NET SDK image to compile the code
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the project file and restore dependencies (this layer is cached)
COPY ["pulse-app.csproj", "./"]
RUN dotnet restore

# Copy everything else and build the release
COPY . .
RUN dotnet publish "pulse-app.csproj" -c Release -o /app/publish /p:UseAppHost=false

# STAGE 2: Runtime
# Use a slim runtime image (much smaller and more secure)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

# Expose the port the app runs on
EXPOSE 8080

# Start the app
ENTRYPOINT ["dotnet", "pulse-app.dll"]