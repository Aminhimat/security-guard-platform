#!/bin/bash

echo "🚀 GitHub Deployment Helper"
echo "=========================="
echo ""

# Check if we're in the right directory
if [ ! -f "SecurityGuardPlatform.sln" ]; then
    echo "❌ Error: Please run this from the project root directory"
    echo "   Current directory: $(pwd)"
    echo "   Expected files: SecurityGuardPlatform.sln"
    exit 1
fi

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "❌ Error: Git repository not found"
    echo "   Run: git init"
    exit 1
fi

echo "✅ Project directory confirmed"
echo "✅ Git repository found"
echo ""

# Ask for GitHub username
echo "📝 Enter your GitHub username:"
read -p "Username: " github_username

if [ -z "$github_username" ]; then
    echo "❌ Error: GitHub username cannot be empty"
    exit 1
fi

# Construct repository URL
repo_url="https://github.com/${github_username}/security-guard-platform.git"

echo ""
echo "🔗 Repository URL: $repo_url"
echo ""

# Check if remote already exists
if git remote get-url origin &> /dev/null; then
    echo "⚠️  Remote 'origin' already exists. Removing it..."
    git remote remove origin
fi

echo "📡 Adding remote repository..."
git remote add origin "$repo_url"

if [ $? -eq 0 ]; then
    echo "✅ Remote added successfully"
else
    echo "❌ Failed to add remote"
    exit 1
fi

echo ""
echo "🚀 Pushing to GitHub..."
echo "   This will upload all 182 files to your repository"
echo ""

git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCESS! Your Security Guard Platform is now on GitHub!"
    echo ""
    echo "📍 Repository URL: https://github.com/${github_username}/security-guard-platform"
    echo ""
    echo "🚀 Next Steps - Deploy to hosting:"
    echo "   1. Railway: https://railway.app (recommended)"
    echo "   2. Render: https://render.com (free tier)"
    echo ""
    echo "📖 Check DEPLOYMENT_GUIDE.md for detailed instructions"
else
    echo ""
    echo "❌ Push failed. Common issues:"
    echo "   1. Make sure you created the repository on GitHub"
    echo "   2. Check your GitHub username is correct"
    echo "   3. Ensure the repository is public"
    echo "   4. Make sure you're signed in to GitHub"
    echo ""
    echo "🔧 To retry:"
    echo "   ./github-deploy.sh"
fi
