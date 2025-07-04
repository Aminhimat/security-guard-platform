# Quick Frontend Deployment Setup

## Update API URL for Production

### Step 1: Update API Service (Required)

In `web-apps/management_dashboard/lib/services/api_service.dart`, change:

```dart
// Development
static const String baseUrl = 'http://localhost:5010/api';

// Production (update with your deployed backend URL)
static const String baseUrl = 'https://your-backend-app.railway.app/api';
// or
static const String baseUrl = 'https://your-backend-app.onrender.com/api';
```

### Step 2: Build and Deploy

```bash
# Build the Flutter web app
cd web-apps/management_dashboard
flutter build web

# Deploy to Netlify
# Option 1: Drag and drop build/web folder to netlify.com
# Option 2: Use Netlify CLI
npm install -g netlify-cli
netlify deploy --dir=build/web --prod
```

### Step 3: Test Login

Use these test credentials:
- **Company Admin**: admin@testsecurity.com / Admin123!
- **Platform Owner**: owner@platform.com / Platform123!

## Environment Variables for Backend

Set these in your hosting provider:

```bash
# Database (Railway provides this automatically)
DATABASE_URL=postgresql://user:password@host:port/database

# JWT Configuration
JWT_KEY=your-super-secret-key-32-characters-minimum
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://0.0.0.0:$PORT

# Railway/Render specific
PORT=8080  # or whatever port your host uses
```

## Cost Breakdown

### Free Options:
1. **Render (Backend)** + **Supabase (Database)** + **Netlify (Frontend)**
   - Backend: Free (sleeps after 15min)
   - Database: Free 500MB
   - Frontend: Free
   - **Total: $0/month**

### Paid Options:
1. **Railway (Backend + Database)** + **Netlify (Frontend)**
   - Backend + DB: $5/month credit
   - Frontend: Free
   - **Total: ~$5/month**

2. **Heroku (Backend)** + **PostgreSQL add-on** + **Netlify (Frontend)**
   - Backend: $5/month
   - Database: $5/month
   - Frontend: Free
   - **Total: $10/month**

## Database Migration

If moving from SQLite to PostgreSQL, your app will automatically create all tables on first run thanks to the seed data in ApplicationDbContext.

The app supports both:
- **Development**: SQLite (automatic)
- **Production**: PostgreSQL (when ASPNETCORE_ENVIRONMENT=Production)

## Quick Deployment Links

- **Railway**: [railway.app](https://railway.app) (Sign up with GitHub)
- **Render**: [render.com](https://render.com) (Sign up with GitHub)
- **Supabase**: [supabase.com](https://supabase.com) (Free PostgreSQL)
- **Netlify**: [netlify.com](https://netlify.com) (Free static hosting)

## Support

If you need help with deployment:
1. Check the detailed DEPLOYMENT_GUIDE.md
2. Run ./deploy.sh for step-by-step instructions
3. Check hosting provider documentation
