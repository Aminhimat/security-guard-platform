# Security Guard Management Platform - Deployment Guide

## 📁 Project Structure
```
SecurityGuardPlatform/
├── README.md                           # Main project documentation
├── SecurityGuardPlatform.sln          # Solution file
├── .github/
│   └── copilot-instructions.md        # AI coding guidelines
├── backend/
│   └── src/
│       ├── SecurityGuardPlatform.API/          # Web API
│       ├── SecurityGuardPlatform.Core/         # Domain entities
│       ├── SecurityGuardPlatform.Application/  # Business logic
│       └── SecurityGuardPlatform.Infrastructure/ # Data access
├── mobile-app/
│   └── guard_app/                      # Flutter mobile app
├── frontend/                           # Web admin dashboard (future)
├── database/                           # SQL scripts (future)
├── docs/                              # Documentation
└── scripts/                           # Deployment scripts

```

## 🚀 Quick Start Guide

### Prerequisites
- .NET 9.0 SDK or later
- SQL Server (LocalDB for development)
- Flutter 3.32+ with Dart 3.8+
- Visual Studio Code or Visual Studio 2022

### Backend Setup

1. **Restore packages and build**:
   ```bash
   cd backend/src/SecurityGuardPlatform.API
   dotnet restore
   dotnet build
   ```

2. **Update database connection** in `appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=SecurityGuardPlatformDb;Trusted_Connection=true;"
     }
   }
   ```

3. **Create database**:
   ```bash
   dotnet ef database update
   ```

4. **Run the API**:
   ```bash
   dotnet run
   ```
   API will be available at: `https://localhost:7000`

### Mobile App Setup

1. **Get Flutter dependencies**:
   ```bash
   cd mobile-app/guard_app
   flutter pub get
   ```

2. **Update API endpoint** in `lib/core/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'https://your-api-url.com/api';
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Backend Configuration (appsettings.json)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Your-SQL-Server-Connection-String"
  },
  "Jwt": {
    "Key": "YourSuperSecretKeyThatIsAtLeast32CharactersLong12345!",
    "Issuer": "SecurityGuardPlatform",
    "Audience": "SecurityGuardPlatformUsers",
    "ExpiryMinutes": 60
  }
}
```

### Flutter App Configuration
- Update API base URL in `api_service.dart`
- Configure permissions in `android/app/src/main/AndroidManifest.xml`
- Set up iOS permissions in `ios/Runner/Info.plist`

## 🔐 Default Test Users

The system will be seeded with these roles:
- **Platform Owner**: Super admin access
- **Company Admin**: Tenant management
- **Supervisor**: Guard oversight  
- **Guard**: Mobile app access

## 📊 API Endpoints

Once running, visit `https://localhost:7000/swagger` for complete API documentation.

Key endpoints:
- `POST /api/auth/login` - User authentication
- `GET /api/auth/me` - Current user info
- `POST /api/auth/register` - Create user (admin only)

## 🎯 Current Features

### ✅ Implemented
- Multi-tenant architecture
- JWT authentication
- Role-based authorization
- User management
- Mobile app foundation
- Database with proper relationships

### 🚧 Ready to Implement (Templates Ready)
- GPS tracking and geofencing
- QR/NFC checkpoint scanning
- Incident reporting with media
- Real-time notifications
- Admin web dashboard

## 🛠️ Development Tools

### Visual Studio Code Tasks
Use Ctrl+Shift+P → "Tasks: Run Task" → "Build and Run Security Guard Platform"

### Debugging
- Backend: Use F5 in Visual Studio Code
- Mobile: Use `flutter run` with hot reload

## 📈 Scaling Considerations

### Production Deployment
1. **Database**: Use Azure SQL Database or AWS RDS
2. **API Hosting**: Deploy to Azure App Service or AWS Elastic Beanstalk
3. **Mobile App**: Build for iOS App Store and Google Play Store
4. **File Storage**: Configure AWS S3 or Azure Blob Storage

### Performance
- Implement caching with Redis
- Add API rate limiting
- Use CDN for static files
- Consider database indexing

## 🔒 Security Checklist

- [ ] Change default JWT secret key
- [ ] Enable HTTPS in production
- [ ] Configure CORS properly
- [ ] Implement API rate limiting
- [ ] Set up proper logging and monitoring
- [ ] Regular security updates

## 📞 Support

This is a comprehensive reference implementation. The code is well-documented and follows industry best practices for:
- Clean Architecture
- Multi-tenant SaaS applications
- Mobile app development
- Security and authentication

---

**Ready for immediate development and extension!** 🚀
