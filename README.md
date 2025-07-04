# Security Guard Management Platform (SaaS)

A comprehensive multi-tenant security guard management platform similar to Silvertrac, built with ASP.NET Core, Entity Framework Core, and Flutter.

## 🏗️ Architecture Overview

### Multi-Tenant SaaS Platform
- **Platform Owner** (Super Admin): Manages multiple security companies
- **Security Company Admin**: Manages their own guards, sites, and operations
- **Guards**: Mobile app for patrol duties, check-ins, and incident reporting

### Technology Stack
- **Backend**: ASP.NET Core 9.0 Web API
- **Database**: SQL Server with Entity Framework Core
- **Mobile**: Flutter (Android & iOS)
- **Authentication**: JWT with role-based access control
- **Cloud Storage**: Support for AWS S3/Azure Blob
- **Maps**: Google Maps/Mapbox integration ready

## 🚀 Features

### Platform Owner Admin Panel (Super Admin)
- ✅ Create and manage security companies (tenants)
- ✅ Set user account limits per company
- ✅ Upgrade/downgrade subscription plans
- ✅ View platform-wide usage and billing
- ✅ Multi-tenant data isolation

### Security Company Admin Panel
- ✅ Company-specific dashboard and login
- ✅ Add/edit guards and supervisors (within user limits)
- 🚧 Manage patrol sites and schedules
- 🚧 View guard check-ins and GPS tracking
- 🚧 Generate reports for clients
- ✅ Role-based access control

### Mobile App for Guards
- ✅ Secure login with company credentials
- 🚧 Check in/out of shifts
- 🚧 Real-time GPS tracking while on duty
- 🚧 QR/NFC checkpoint scanning
- 🚧 Submit incident reports with photos/audio
- 🚧 Emergency alert functionality
- ✅ Offline capability foundation

### Core Security Features
- ✅ JWT authentication with refresh tokens
- ✅ Multi-tenant data isolation at database level
- ✅ Role-based authorization policies
- ✅ Input validation and sanitization
- ✅ Comprehensive audit logging
- ✅ Secure password requirements

## 📱 Mobile App Features

### Current Status
- ✅ Authentication system
- ✅ User profile management
- ✅ Dashboard with quick actions
- ✅ Offline storage foundation
- 🚧 GPS tracking service
- 🚧 QR code scanning
- 🚧 Incident reporting
- 🚧 Check-in system

### Planned Features
- Emergency alert system
- Patrol route management
- Photo/audio evidence capture
- Real-time notifications
- Offline data synchronization

## 🛠️ Development Setup

### Prerequisites
- .NET 9.0 SDK
- SQL Server (LocalDB for development)
- Flutter 3.32+ 
- Visual Studio Code or Visual Studio 2022

### Backend Setup

1. **Clone and Build**
   ```bash
   cd backend/src
   dotnet restore
   dotnet build
   ```

2. **Database Setup**
   ```bash
   cd SecurityGuardPlatform.API
   dotnet ef database update
   ```

3. **Run API**
   ```bash
   dotnet run
   ```
   API will be available at `https://localhost:7000`

### Mobile App Setup

1. **Install Dependencies**
   ```bash
   cd mobile-app/guard_app
   flutter pub get
   ```

2. **Update API URL**
   Edit `lib/core/services/api_service.dart` and update the `baseUrl`

3. **Run App**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Backend Configuration (appsettings.json)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=SecurityGuardPlatformDb;Trusted_Connection=true;"
  },
  "Jwt": {
    "Key": "YourSuperSecretKey",
    "Issuer": "SecurityGuardPlatform",
    "Audience": "SecurityGuardPlatformUsers",
    "ExpiryMinutes": 60
  }
}
```

### Mobile App Configuration
Update the API base URL in `lib/core/services/api_service.dart`

## 📊 Database Schema

### Core Entities
- **Tenant**: Security companies (multi-tenant isolation)
- **User**: Platform owners, company admins, supervisors, guards
- **Site**: Client locations with geofencing
- **Checkpoint**: QR/NFC scan points within sites
- **Shift**: Work schedules for guards
- **CheckIn**: Guard checkpoint scans and GPS logs
- **IncidentReport**: Incident documentation with media
- **LocationLog**: Real-time GPS tracking data

### Multi-Tenant Architecture
- Shared database with tenant isolation
- Global query filters for data separation
- Tenant-aware repositories and services

## 🔐 Security & Permissions

### Role Hierarchy
1. **Platform Owner**: Full system access
2. **Company Admin**: Full access within their tenant
3. **Supervisor**: Limited management within their tenant
4. **Guard**: Mobile app access and basic operations

### Authorization Policies
- `PlatformOwnerOnly`: Super admin features
- `CompanyAdminAndAbove`: Tenant management
- `SupervisorAndAbove`: Guard oversight
- `AllRoles`: Basic authenticated features

## 🚧 Current Development Status

### ✅ Completed
- Project structure and architecture
- Multi-tenant database design
- Identity and authentication system
- Basic API controllers
- Flutter app foundation with BLoC pattern
- Core services (API, Storage, Location)
- Login and dashboard UI

### 🚧 In Progress
- Additional API controllers (Shifts, Incidents, Check-ins)
- Mobile app features (GPS tracking, QR scanning)
- Admin dashboard web interface
- File upload and cloud storage integration

### 📋 TODO
- [ ] Complete API endpoints
- [ ] Admin web dashboard
- [ ] QR code generation and scanning
- [ ] Real-time GPS tracking
- [ ] Incident reporting with media
- [ ] Email/SMS notifications
- [ ] Payment integration
- [ ] Client portal
- [ ] Advanced reporting and analytics
- [ ] Docker containerization
- [ ] Azure/AWS deployment scripts

## 📚 API Documentation

Once running, visit `https://localhost:7000/swagger` for interactive API documentation.

### Key Endpoints
- `POST /api/auth/login` - User authentication
- `GET /api/auth/me` - Current user info
- `POST /api/auth/register` - Create new user (admin only)
- More endpoints coming...

## 🤝 Contributing

This is a comprehensive reference implementation of a multi-tenant security guard management platform. Feel free to extend and customize for your specific needs.

### Development Guidelines
- Follow clean architecture principles
- Implement proper error handling
- Write unit tests for business logic
- Use async/await for all I/O operations
- Maintain multi-tenant data isolation

## 📄 License

This project is provided as-is for educational and reference purposes.

---

**Built with ❤️ using ASP.NET Core, Entity Framework Core, and Flutter**
