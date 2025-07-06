# Deploy to Azure (Microsoft's Platform)

Azure has native .NET support and is very reliable for ASP.NET Core applications.

## Step 1: Install Azure CLI

### macOS:
```bash
brew install azure-cli
```

### Other platforms:
Download from [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Step 2: Login to Azure

```bash
az login
```

## Step 3: Create Resource Group

```bash
az group create --name security-guard-rg --location eastus
```

## Step 4: Create PostgreSQL Database

```bash
az postgres flexible-server create \
  --resource-group security-guard-rg \
  --name security-guard-db \
  --location eastus \
  --admin-user dbadmin \
  --admin-password "YourStrongPassword123!" \
  --sku-name Standard_B1ms \
  --storage-size 32 \
  --version 14
```

## Step 5: Create App Service Plan

```bash
az appservice plan create \
  --resource-group security-guard-rg \
  --name security-guard-plan \
  --is-linux \
  --sku F1
```

## Step 6: Create Web App

```bash
az webapp create \
  --resource-group security-guard-rg \
  --plan security-guard-plan \
  --name security-guard-api \
  --runtime "DOTNETCORE|8.0"
```

## Step 7: Configure Environment Variables

```bash
# Database connection
az webapp config appsettings set \
  --resource-group security-guard-rg \
  --name security-guard-api \
  --settings DATABASE_URL="postgresql://dbadmin:YourStrongPassword123!@security-guard-db.postgres.database.azure.com:5432/postgres"

# JWT settings
az webapp config appsettings set \
  --resource-group security-guard-rg \
  --name security-guard-api \
  --settings JWT_KEY="your-super-secret-jwt-key-minimum-32-characters-long"

az webapp config appsettings set \
  --resource-group security-guard-rg \
  --name security-guard-api \
  --settings JWT_ISSUER="SecurityGuardPlatform"

az webapp config appsettings set \
  --resource-group security-guard-rg \
  --name security-guard-api \
  --settings JWT_AUDIENCE="SecurityGuardPlatformUsers"

az webapp config appsettings set \
  --resource-group security-guard-rg \
  --name security-guard-api \
  --settings ASPNETCORE_ENVIRONMENT="Production"
```

## Step 8: Deploy from GitHub

```bash
# Configure GitHub deployment
az webapp deployment source config \
  --resource-group security-guard-rg \
  --name security-guard-api \
  --repo-url https://github.com/YOUR_USERNAME/security-guard-platform \
  --branch main \
  --manual-integration
```

## Alternative: Deploy using Azure DevOps

1. Go to [https://dev.azure.com](https://dev.azure.com)
2. Create a new project
3. Connect your GitHub repository
4. Create a build pipeline for .NET Core
5. Create a release pipeline to deploy to App Service

## Alternative: Deploy using VS Code

1. Install Azure App Service extension
2. Right-click on your project
3. Select "Deploy to Web App"
4. Choose your Azure subscription and app

## Your API URL

Your API will be available at: `https://security-guard-api.azurewebsites.net`

## Troubleshooting

### View logs:
```bash
az webapp log tail --resource-group security-guard-rg --name security-guard-api
```

### SSH into container:
```bash
az webapp ssh --resource-group security-guard-rg --name security-guard-api
```

### Scale app:
```bash
az appservice plan update \
  --resource-group security-guard-rg \
  --name security-guard-plan \
  --sku S1
```

---

## Pros of Azure:
- ✅ Native .NET support
- ✅ Excellent integration with Visual Studio
- ✅ Enterprise-grade security
- ✅ Global CDN and availability
- ✅ Built-in monitoring and logging

## Cons of Azure:
- ❌ Can be complex for beginners
- ❌ More expensive than some alternatives
- ❌ Requires learning Azure concepts

## Cost Optimization

### Free Tier Options:
- App Service: F1 (Free tier)
- PostgreSQL: Burstable B1ms (cheapest option)
- Total cost: ~$15-20/month for small applications

### Student Benefits:
Azure offers $100 credit for students: [https://azure.microsoft.com/en-us/free/students/](https://azure.microsoft.com/en-us/free/students/)
