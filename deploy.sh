#!/bin/bash

# Deployment script for Security Guard Platform

echo "🚀 Security Guard Platform Deployment Script"
echo "============================================="

# Function to deploy to Railway
deploy_railway() {
    echo "📡 Deploying to Railway..."
    echo ""
    echo "1. Install Railway CLI:"
    echo "   npm install -g @railway/cli"
    echo ""
    echo "2. Login to Railway:"
    echo "   railway login"
    echo ""
    echo "3. Create new project:"
    echo "   railway new"
    echo ""
    echo "4. Add PostgreSQL database:"
    echo "   railway add postgresql"
    echo ""
    echo "5. Deploy the application:"
    echo "   railway up"
    echo ""
    echo "6. Set environment variables in Railway dashboard:"
    echo "   - JWT_KEY: $(openssl rand -base64 32)"
    echo "   - ASPNETCORE_ENVIRONMENT: Production"
    echo ""
}

# Function to deploy to Render
deploy_render() {
    echo "🌐 Deploying to Render..."
    echo ""
    echo "1. Create account at https://render.com"
    echo "2. Connect your GitHub repository"
    echo "3. Create new Web Service with these settings:"
    echo "   - Build Command: dotnet publish -c Release -o /app/publish"
    echo "   - Start Command: dotnet /app/publish/SecurityGuardPlatform.API.dll"
    echo "   - Environment: Docker"
    echo ""
    echo "4. Set environment variables:"
    echo "   - DATABASE_URL: [Get from Supabase or other PostgreSQL provider]"
    echo "   - JWT_KEY: $(openssl rand -base64 32)"
    echo "   - ASPNETCORE_ENVIRONMENT: Production"
    echo "   - ASPNETCORE_URLS: http://0.0.0.0:10000"
    echo ""
}

# Function to prepare frontend for deployment
prepare_frontend() {
    echo "🎨 Preparing Frontend for Deployment..."
    echo ""
    echo "1. Update API base URL in api_service.dart"
    echo "2. Build Flutter web app:"
    echo "   cd web-apps/management_dashboard"
    echo "   flutter build web"
    echo ""
    echo "3. Deploy to Netlify:"
    echo "   - Drag and drop build/web folder to Netlify"
    echo "   - Or connect GitHub repo and set build settings:"
    echo "     - Build command: flutter build web"
    echo "     - Publish directory: build/web"
    echo ""
}

# Function to create GitHub repository
setup_github() {
    echo "📱 Setting up GitHub Repository..."
    echo ""
    echo "1. Create new repository on GitHub"
    echo "2. Initialize git and push code:"
    echo "   git init"
    echo "   git add ."
    echo "   git commit -m 'Initial commit - Security Guard Platform'"
    echo "   git branch -M main"
    echo "   git remote add origin https://github.com/yourusername/security-guard-platform.git"
    echo "   git push -u origin main"
    echo ""
}

# Main menu
echo "Choose deployment option:"
echo "1. Railway (Recommended - $5/month credit)"
echo "2. Render + Supabase (Free with limitations)"
echo "3. Prepare Frontend"
echo "4. Setup GitHub Repository"
echo "5. Show all deployment options"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        deploy_railway
        ;;
    2)
        deploy_render
        ;;
    3)
        prepare_frontend
        ;;
    4)
        setup_github
        ;;
    5)
        echo "🌟 All Deployment Options:"
        echo ""
        deploy_railway
        echo ""
        deploy_render
        echo ""
        prepare_frontend
        echo ""
        setup_github
        ;;
    *)
        echo "Invalid choice. Please run the script again."
        ;;
esac

echo ""
echo "🎉 Deployment preparation complete!"
echo "📚 Check DEPLOYMENT_GUIDE.md for detailed instructions"
