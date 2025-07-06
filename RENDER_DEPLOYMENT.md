# Deploy to Render (Easy Railway Alternative)

Render is the best Railway alternative for deploying .NET Core applications. It's simple, reliable, and has excellent .NET support.

## Step 1: Create Render Account

1. Go to [https://render.com](https://render.com)
2. Sign up with your GitHub account
3. This will automatically connect your GitHub repositories

## Step 2: Create PostgreSQL Database

1. In Render dashboard, click **"New +"**
2. Select **"PostgreSQL"**
3. Configure:
   - **Name**: `security-guard-db`
   - **Database**: `security_guard_platform`
   - **User**: `admin`
   - **Region**: Choose closest to your users
   - **Plan**: Start with **Free** (can upgrade later)
4. Click **"Create Database"**
5. **Save the connection details** - you'll need them for the API

## Step 3: Deploy the API

1. In Render dashboard, click **"New +"**
2. Select **"Web Service"**
3. Connect your GitHub repository: `security-guard-platform`
4. Configure:
   - **Name**: `security-guard-api`
   - **Runtime**: **Docker**
   - **Branch**: `main`
   - **Root Directory**: `backend`
   - **Dockerfile Path**: `backend/Dockerfile`

## Step 4: Configure Environment Variables

In the **Environment Variables** section, add:

```
DATABASE_URL=postgresql://admin:PASSWORD@HOST:5432/security_guard_platform
JWT_KEY=your-super-secret-jwt-key-here-minimum-32-characters
JWT_ISSUER=SecurityGuardPlatform
JWT_AUDIENCE=SecurityGuardPlatformUsers
ASPNETCORE_ENVIRONMENT=Production
```

**Important**: Replace `PASSWORD` and `HOST` with the actual values from your PostgreSQL database (from Step 2).

## Step 5: Deploy

1. Click **"Create Web Service"**
2. Render will automatically:
   - Clone your repository
   - Build the Docker image
   - Deploy your API
   - Provide you with a live URL

## Step 6: Test Your API

Your API will be available at: `https://your-app-name.onrender.com`

Test endpoints:
- `GET /api/health` - Health check
- `GET /api/auth/test` - Test authentication
- `POST /api/auth/register` - User registration

## Step 7: Update Frontend

Update your frontend applications to use the new API URL:

**Management Dashboard**: `web-apps/management_dashboard/lib/services/api_service.dart`
**Mobile App**: `mobile-app/guard_app/lib/services/api_service.dart`

Change the baseUrl to your Render URL:
```dart
static const String baseUrl = 'https://your-app-name.onrender.com/api';
```

## Benefits of Render over Railway:

✅ **Better .NET Support** - Render has more reliable .NET builds
✅ **Integrated PostgreSQL** - Built-in database service
✅ **Automatic SSL** - HTTPS enabled by default
✅ **Zero Configuration** - Auto-detects your project setup
✅ **Free Tier** - 750 hours/month free
✅ **Reliable Builds** - Fewer build failures than Railway
✅ **Better Logs** - More detailed deployment logs

## Troubleshooting

If you encounter issues:

1. **Check the build logs** in Render dashboard
2. **Verify environment variables** are set correctly
3. **Test database connection** using the PostgreSQL connection string
4. **Check the Dockerfile** path is correct (`backend/Dockerfile`)

## Cost Comparison

- **Render Free**: 750 hours/month, PostgreSQL included
- **Railway**: $5/month minimum after trial
- **Render Pro**: $7/month for web service + $7/month for PostgreSQL

Render is more cost-effective and reliable for .NET applications!
