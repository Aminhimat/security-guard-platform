# Deploy to Heroku (Easy Alternative)

Heroku is a classic Platform-as-a-Service that's very beginner-friendly.

## Step 1: Install Heroku CLI

### macOS (using Homebrew):
```bash
brew tap heroku/brew && brew install heroku
```

### Other platforms:
Download from [https://devcenter.heroku.com/articles/heroku-cli](https://devcenter.heroku.com/articles/heroku-cli)

## Step 2: Login to Heroku

```bash
heroku login
```

## Step 3: Create Heroku App

```bash
# Navigate to your project root
cd /Users/amin/Desktop/untitled\ folder\ 4

# Create Heroku app
heroku create security-guard-platform

# Add PostgreSQL database
heroku addons:create heroku-postgresql:mini
```

## Step 4: Configure for .NET Deployment

Create a `Procfile` in your project root:

```
web: cd backend/src/SecurityGuardPlatform.API && dotnet SecurityGuardPlatform.API.dll --urls=http://0.0.0.0:$PORT
```

## Step 5: Set Environment Variables

```bash
# Set JWT configuration
heroku config:set JWT_KEY="your-super-secret-jwt-key-minimum-32-characters-long"
heroku config:set JWT_ISSUER="SecurityGuardPlatform"
heroku config:set JWT_AUDIENCE="SecurityGuardPlatformUsers"
heroku config:set ASPNETCORE_ENVIRONMENT="Production"

# The DATABASE_URL is automatically set by the PostgreSQL add-on
```

## Step 6: Deploy

```bash
# Add all files to git
git add .
git commit -m "Deploy to Heroku"

# Push to Heroku
git push heroku main
```

## Step 7: Open Your App

```bash
heroku open
```

Your API will be available at: `https://security-guard-platform.herokuapp.com`

## Troubleshooting

### Check logs:
```bash
heroku logs --tail
```

### Run database migrations:
```bash
heroku run dotnet ef database update --project backend/src/SecurityGuardPlatform.API
```

### Scale your app:
```bash
heroku ps:scale web=1
```

---

## Pros of Heroku:
- ✅ Very easy to set up
- ✅ Automatic HTTPS
- ✅ Built-in PostgreSQL
- ✅ Great logging and monitoring
- ✅ CLI tools

## Cons of Heroku:
- ❌ Free tier has sleep mode (30 min inactivity)
- ❌ More expensive than alternatives
- ❌ Limited customization

## Alternative: Use Heroku with Container

If you prefer Docker deployment:

```bash
# Login to Heroku container registry
heroku container:login

# Push and release
heroku container:push web --app security-guard-platform
heroku container:release web --app security-guard-platform
```
