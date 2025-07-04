# Railway-specific Dockerfile for SecurityGuardPlatform API
# This Dockerfile is optimized for Railway deployment

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy project files
COPY src/SecurityGuardPlatform.API/*.csproj ./SecurityGuardPlatform.API/
COPY src/SecurityGuardPlatform.Core/*.csproj ./SecurityGuardPlatform.Core/
COPY src/SecurityGuardPlatform.Application/*.csproj ./SecurityGuardPlatform.Application/
COPY src/SecurityGuardPlatform.Infrastructure/*.csproj ./SecurityGuardPlatform.Infrastructure/

# Restore dependencies
RUN dotnet restore SecurityGuardPlatform.API/SecurityGuardPlatform.API.csproj

# Copy source code
COPY src/ ./

# Build and publish
WORKDIR /app/SecurityGuardPlatform.API
RUN dotnet publish -c Release -o /app/publish

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Copy published application
COPY --from=build /app/publish ./

# Expose port
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://0.0.0.0:8080

# Run the application
ENTRYPOINT ["dotnet", "SecurityGuardPlatform.API.dll"]
