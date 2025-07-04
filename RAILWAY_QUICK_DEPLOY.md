# Railway Deployment Quick Guide

## 🚀 Deploy Your API to Railway

### Step 1: In Railway Dashboard
1. **Create New Service** → **GitHub Repo**
2. **Select Repository**: `Aminhimat/security-guard-platform`
3. **Set Root Directory**: `backend`
4. **Railway will auto-detect**: .NET project

### Step 2: Environment Variables
Add these in Railway → Settings → Environment Variables:

```
DATABASE_URL=${{Postgres.DATABASE_URL}}
JWT_KEY=DgSj7DfqIByywAVHhtNq4Nupq8qBq86Z9phw2GAuRIw=
JWT_ISSUER=SecurityGuardPlatform
JWT_AUDIENCE=SecurityGuardPlatformUsers
ASPNETCORE_ENVIRONMENT=Production
PORT=8080
```

### Step 3: Build Settings (Auto-detected)
- **Builder**: Nixpacks or Dockerfile
- **Build Command**: `dotnet publish -c Release -o /app/bin`
- **Start Command**: `dotnet /app/bin/SecurityGuardPlatform.API.dll`

### Step 4: Deploy
- Railway will automatically build and deploy
- Check build logs for any errors
- Your API will be available at: `https://your-service.up.railway.app`

### Step 5: Test Your API
Test these endpoints once deployed:
- `GET /api/health` (if available)
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/management/guards`

### Troubleshooting
- Check **Build Logs** for compilation errors
- Check **Deploy Logs** for runtime errors
- Ensure PostgreSQL service is running
- Verify environment variables are set correctly

### Alternative: Use Different Root Directory
If the backend folder detection doesn't work:
1. Set **Root Directory**: `backend/src/SecurityGuardPlatform.API`
2. Or use the main project Dockerfile (set root to project root)

## 🎯 Next Steps After Successful Deploy
1. **Note your API URL**: `https://your-service.up.railway.app`
2. **Update Frontend**: Change API base URL in Flutter web app
3. **Deploy Frontend**: Build and deploy to Netlify
4. **Test Full Stack**: Login → View guards → Create incidents

Your API should now be live and connected to PostgreSQL! 🎉
