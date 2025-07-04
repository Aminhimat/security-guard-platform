class AppConstants {
  static const String appName = 'Security Guard App';
  static const String apiBaseUrl = 'http://10.0.2.2:5010/api'; // For Android emulator
  // static const String apiBaseUrl = 'http://localhost:5010/api'; // For iOS simulator
  
  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String checkInEndpoint = '/patrol/checkin';
  static const String incidentsEndpoint = '/incidents';
  static const String locationEndpoint = '/location/update';
  static const String uploadEndpoint = '/upload';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String companyDataKey = 'company_data';
  static const String offlineDataKey = 'offline_data';
  
  // Settings
  static const int locationUpdateIntervalSeconds = 30;
  static const double geofenceRadiusMeters = 100.0;
  static const double maxImageSize = 5.0; // MB
  static const int imageQuality = 85;
  static const bool enableOfflineMode = true;
  
  // Colors
  static const primaryColor = 0xFF1E3C72;
  static const secondaryColor = 0xFF2A5298;
  static const errorColor = 0xFFB00020;
  static const successColor = 0xFF4CAF50;
  static const warningColor = 0xFFFF9800;
}

// Route names
class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String incidentReport = '/incident-report';
  static const String camera = '/camera';
  static const String patrolRoutes = '/patrol-routes';
  static const String checkInOut = '/check-in-out';
  static const String qrScanner = '/qr-scanner';
  static const String emergency = '/emergency';
}
