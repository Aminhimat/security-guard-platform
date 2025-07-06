# Deployment Guide for Security Guard Management Platform

## 🎯 Easy Railway Alternatives (Ranked by Easiness)

### 1. **Render + Supabase** (Easiest & Most Reliable)
- **Difficulty**: ⭐⭐ (Beginner friendly)
- **Cost**: Free tier available
- **Setup Time**: 15 minutes
- **Guide**: See `EASY_DEPLOY.md`

### 2. **Heroku** (Classic Choice)
- **Difficulty**: ⭐⭐ (Very beginner friendly)
- **Cost**: Free tier with limitations
- **Setup Time**: 10 minutes
- **Guide**: See `HEROKU_DEPLOYMENT.md`

### 3. **Azure App Service** (Microsoft's Platform)
- **Difficulty**: ⭐⭐⭐ (Intermediate)
- **Cost**: Free tier available
- **Setup Time**: 20 minutes
- **Guide**: See `AZURE_DEPLOYMENT.md`

### 4. **DigitalOcean App Platform**
- **Difficulty**: ⭐⭐ (Easy)
- **Cost**: $5/month minimum
- **Setup Time**: 15 minutes

---

## 🚀 Quick Start (Render + Supabase)

**The easiest and most reliable option:**

1. **Database**: Create free Supabase PostgreSQL database
2. **Backend**: Deploy to Render using Docker
3. **Frontend**: Deploy to Netlify (drag & drop)

**See detailed instructions in: `EASY_DEPLOY.md`**

---

## ❌ Railway (Not Recommended)

*Note: Railway has been unreliable with environment variables and PostgreSQL connections. We recommend using the alternatives above.*

### Backend API Deployment
1. **Prepare for PostgreSQL**:
   - Update `appsettings.json` to use PostgreSQL connection string
   - Update Entity Framework to use PostgreSQL instead of SQLite

2. **Railway Setup**:
   - Sign up at [railway.app](https://railway.app)
   - Connect your GitHub repository
   - Add PostgreSQL database service
   - Deploy API service

3. **Environment Variables**:
   ```
   DATABASE_URL=postgresql://username:password@host:port/database
   JWT_KEY=your-secret-key-here
   ASPNETCORE_ENVIRONMENT=Production
   ```

### Frontend Web App Deployment
1. **Netlify Setup**:
   - Build your Flutter web app: `flutter build web`
   - Upload `build/web` folder to Netlify
   - Update API base URL to point to Railway backend

## Option 2: Render + Supabase

### Database Setup (Supabase)
1. Sign up at [supabase.com](https://supabase.com)
2. Create new project
3. Get PostgreSQL connection string
4. Run migrations to create tables

### Backend API (Render)
1. Sign up at [render.com](https://render.com)
2. Create new Web Service
3. Connect GitHub repository
4. Set build command: `dotnet publish -c Release -o out`
5. Set start command: `dotnet out/SecurityGuardPlatform.API.dll`

### Frontend (Netlify)
1. Build: `flutter build web`
2. Deploy to Netlify
3. Update API endpoints

## Database Migration from SQLite to PostgreSQL

### 1. Install PostgreSQL EF Package
```bash
cd backend/src/SecurityGuardPlatform.Infrastructure
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
```

### 2. Update DbContext
```csharp
// In Program.cs
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));
```

### 3. Update Connection String
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=securityguard;Username=postgres;Password=password"
  }
}
```

### 4. Generate Migration
```bash
dotnet ef migrations add InitialPostgreSQL
dotnet ef database update
```

## Environment Configuration

### Backend Environment Variables
```
DATABASE_URL=your_postgresql_connection_string
JWT_KEY=your_jwt_secret_key_32_chars_minimum
JWT_ISSUER=SecurityGuardPlatform
JWT_AUDIENCE=SecurityGuardPlatformUsers
ASPNETCORE_ENVIRONMENT=Production
```

### Frontend Environment Variables
```
API_BASE_URL=https://your-backend-api.railway.app/api
```

## Cost Breakdown

### Railway Option (Recommended)
- **Cost**: $5/month credit (covers small usage)
- **Includes**: API hosting + PostgreSQL database
- **Frontend**: Free on Netlify
- **Total**: Effectively free for small usage

### Render + Supabase Option
- **Backend**: Free (sleeps after 15min inactivity)
- **Database**: Free (500MB limit)
- **Frontend**: Free
- **Total**: Completely free (with limitations)

## Production Checklist

### Security
- [ ] Use strong JWT secrets
- [ ] Enable HTTPS only
- [ ] Set up proper CORS policies
- [ ] Use environment variables for secrets

### Performance
- [ ] Enable response compression
- [ ] Set up database connection pooling
- [ ] Configure proper caching headers

### Monitoring
- [ ] Set up application logging
- [ ] Configure health checks
- [ ] Monitor database performance

## Custom Domain Setup

### Backend
- Railway: Add custom domain in project settings
- Render: Add custom domain in service settings

### Frontend
- Netlify: Add custom domain in site settings
- Update CORS settings in backend

## Database Backup

### Railway
- Automatic backups included
- Can export database manually

### Supabase
- Automatic backups included
- Can export via dashboard

## Scaling Options

### When you outgrow free tiers:
1. **Railway**: Upgrade to paid plan ($5-20/month)
2. **Render**: Upgrade to paid plan ($7-25/month)
3. **Database**: Upgrade to paid PostgreSQL ($7-15/month)

## Alternative Hosting Options

### If you prefer other providers:
- **Heroku**: $5/month hobby plan
- **Azure**: Free tier available
- **DigitalOcean**: $4/month droplet
- **AWS**: Free tier (12 months)

## Support and Resources

- Railway: [docs.railway.app](https://docs.railway.app)
- Render: [render.com/docs](https://render.com/docs)
- Supabase: [supabase.com/docs](https://supabase.com/docs)
- Netlify: [docs.netlify.com](https://docs.netlify.com)
