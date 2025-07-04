# Multi-stage Dockerfile for Security Guard Platform API

# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["backend/src/SecurityGuardPlatform.API/SecurityGuardPlatform.API.csproj", "SecurityGuardPlatform.API/"]
COPY ["backend/src/SecurityGuardPlatform.Application/SecurityGuardPlatform.Application.csproj", "SecurityGuardPlatform.Application/"]
COPY ["backend/src/SecurityGuardPlatform.Core/SecurityGuardPlatform.Core.csproj", "SecurityGuardPlatform.Core/"]
COPY ["backend/src/SecurityGuardPlatform.Infrastructure/SecurityGuardPlatform.Infrastructure.csproj", "SecurityGuardPlatform.Infrastructure/"]

RUN dotnet restore "SecurityGuardPlatform.API/SecurityGuardPlatform.API.csproj"

# Copy source code
COPY backend/src/ .

# Build the application
WORKDIR "/src/SecurityGuardPlatform.API"
RUN dotnet build "SecurityGuardPlatform.API.csproj" -c Release -o /app/build

# Publish Stage
FROM build AS publish
RUN dotnet publish "SecurityGuardPlatform.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime
WORKDIR /app

# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy published app
COPY --from=publish /app/publish .

# Create logs directory
RUN mkdir -p logs && chown -R appuser:appuser logs

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Start the application
ENTRYPOINT ["dotnet", "SecurityGuardPlatform.API.dll"]
