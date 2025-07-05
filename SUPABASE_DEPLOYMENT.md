# Supabase + Render Deployment Guide

This is a much more reliable deployment option than Railway.

## Step 1: Set up Supabase Database

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New project"
3. Choose your organization
4. Enter project details:
   - Name: `security-guard-platform`
   - Database Password: (generate a strong password and save it)
   - Region: Choose closest to your users
5. Click "Create new project"
6. Wait 2-3 minutes for database setup

## Step 2: Get Your Connection String

1. In your Supabase project, go to **Settings** → **Database**
2. Scroll down to **Connection String**
3. Copy the **URI** format (it looks like):
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres
   ```
4. Replace `[YOUR-PASSWORD]` with your actual database password

## Step 3: Deploy Backend to Render

1. Go to [render.com](https://render.com) and sign up/login
2. Click "New +" → "Web Service"
3. Connect your GitHub repository: `https://github.com/Aminhimat/security-guard-platform`
4. Configure the service:
   - **Name**: `security-guard-api`
   - **Region**: Same as your Supabase region
   - **Branch**: `main`
   - **Root Directory**: `backend`
   - **Runtime**: `Docker`
   - **Build Command**: (leave empty - uses Dockerfile)
   - **Start Command**: (leave empty - uses Dockerfile)

5. **Environment Variables** (click "Advanced" → "Add Environment Variable"):
   ```
   DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres
   JWT_KEY=YourSuperSecretKeyThatIsAtLeast32CharactersLong12345!
   JWT_ISSUER=SecurityGuardPlatform
   JWT_AUDIENCE=SecurityGuardPlatformUsers
   ASPNETCORE_ENVIRONMENT=Production
   ```

6. Click "Create Web Service"

## Step 4: Test Your API

Once deployment is complete (5-10 minutes), you'll get a URL like:
`https://security-guard-api.onrender.com`

Test these endpoints:
- `GET https://security-guard-api.onrender.com/api/auth/test` - Should return "API is working!"
- `POST https://security-guard-api.onrender.com/api/auth/register` - For user registration

## Step 5: Deploy Frontend to Netlify

1. Build your Flutter web app:
   ```bash
   cd web-apps/management_dashboard
   flutter build web
   ```

2. Go to [netlify.com](https://netlify.com) and login
3. Drag and drop the `build/web` folder to Netlify
4. Your site will be deployed instantly!

## Step 6: Update Frontend API URL

Update your Flutter web app to use the live API:

1. Edit `web-apps/management_dashboard/lib/services/api_service.dart`
2. Change the base URL:
   ```dart
   static const String baseUrl = 'https://security-guard-api.onrender.com/api';
   ```

3. Rebuild and redeploy:
   ```bash
   flutter build web
   # Then upload to Netlify again
   ```

## Step 7: Set up Database Tables

Your API will automatically create the database tables on first run thanks to Entity Framework migrations.

## Cost Breakdown

- **Supabase**: Free (500MB database, 50,000 monthly active users)
- **Render**: Free (sleeps after 15min inactivity, limited hours)
- **Netlify**: Free (100GB bandwidth, continuous deployment)
- **Total**: Completely FREE!

## Advantages over Railway

1. **Reliability**: Supabase is more stable than Railway's PostgreSQL
2. **Simplicity**: Easier setup and configuration
3. **Cost**: Completely free for small projects
4. **Performance**: Better uptime and faster deployment
5. **Support**: Better documentation and community

## Troubleshooting

### If API doesn't start:
1. Check Render logs for connection errors
2. Verify your DATABASE_URL is correct
3. Make sure your Supabase database is running

### If frontend can't connect:
1. Check browser console for CORS errors
2. Verify API URL is correct
3. Make sure API is running and responding

### Database connection issues:
1. Check Supabase project is active
2. Verify connection string format
3. Test connection from Supabase SQL editor
