# Copilot Instructions for Security Guard Management Platform

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Project Overview
This is a multi-tenant Security Guard Management Platform (SaaS) built with:
- **Backend**: ASP.NET Core Web API with Entity Framework Core
- **Database**: SQL Server/PostgreSQL with multi-tenant data isolation
- **Mobile App**: Flutter (Android & iOS)
- **Authentication**: JWT with role-based access control
- **Cloud Storage**: AWS S3/Azure Blob for photos and audio files
- **Maps**: Google Maps/Mapbox for GPS tracking

## Architecture Patterns
- **Multi-tenancy**: Database-per-tenant or shared database with tenant isolation
- **Repository Pattern**: For data access abstraction
- **CQRS**: For complex read/write operations
- **Clean Architecture**: Separation of concerns across layers

## Key Features to Implement
1. **Platform Owner Admin Panel** (Super Admin)
2. **Security Company Admin Panel** (Company Admin) 
3. **Mobile Guard App** (Guard Role)
4. **GPS Tracking & Geofencing**
5. **QR/NFC Checkpoint Scanning**
6. **Incident Reporting** with media uploads
7. **Real-time Notifications**
8. **Billing & Subscription Management**

## Coding Guidelines
- Use Entity Framework Core for all database operations
- Implement proper tenant isolation in all queries
- Use AutoMapper for object mapping
- Implement comprehensive logging with Serilog
- Use FluentValidation for input validation
- Follow RESTful API design principles
- Implement proper error handling and custom exceptions
- Use dependency injection throughout the application
- Write unit tests for business logic
- Use async/await for all I/O operations

## Security Requirements
- JWT authentication with refresh tokens
- Role-based authorization (Platform Owner, Company Admin, Guard)
- Tenant data isolation at database level
- Input validation and sanitization
- Rate limiting for API endpoints
- Secure file upload handling

## Mobile App Guidelines
- Use Flutter BLoC pattern for state management
- Implement offline capabilities for critical features
- Use secure storage for authentication tokens
- Implement proper permission handling for camera, location, etc.
- Follow Material Design guidelines
