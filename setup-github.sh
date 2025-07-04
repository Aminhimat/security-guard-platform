#!/bin/bash

# GitHub Repository Setup for Security Guard Platform
echo "🐙 Setting up GitHub Repository..."

# Step 1: Initialize Git
echo "1. Initializing Git repository..."
git init

# Step 2: Add all files
echo "2. Adding all files to Git..."
git add .

# Step 3: Create initial commit
echo "3. Creating initial commit..."
git commit -m "Initial commit: Security Guard Management Platform

- ASP.NET Core Web API backend with JWT authentication
- Flutter web management dashboard  
- Multi-tenant architecture with PostgreSQL support
- Role-based access control (Platform Owner, Company Admin, Guard)
- Real-time incident reporting and patrol tracking
- Production-ready with Docker and deployment configurations"

# Step 4: Set main branch
echo "4. Setting main branch..."
git branch -M main

echo ""
echo "✅ Local Git repository setup complete!"
echo ""
echo "🌐 Next steps:"
echo "1. Go to https://github.com/new"
echo "2. Create a new repository with name: security-guard-platform"
echo "3. Set it as Public"
echo "4. DON'T initialize with README (we already have files)"
echo "5. Copy the repository URL and run:"
echo ""
echo "   git remote add origin https://github.com/YOUR_USERNAME/security-guard-platform.git"
echo "   git push -u origin main"
echo ""
echo "📝 Suggested repository names:"
echo "   - security-guard-platform"
echo "   - security-guard-management-system" 
echo "   - guard-management-saas"
echo "   - security-management-platform"
