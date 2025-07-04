import 'package:dio/dio.dart';
import '../models/user_model.dart';

class ApiService {
  late final Dio _dio;
  static const String baseUrl = 'http://localhost:5010/api'; // Backend API URL

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add request/response interceptors for logging and auth
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print(object),
    ));
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔐 ApiService.login called with email: $email');
      
      final response = await _dio.post('/Auth/login', data: {
        'email': email,
        'password': password,
      });
      
      print('✅ Login successful: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Login error: ${e.response?.data ?? e.message}');
      throw Exception(_handleError(e));
    } catch (e) {
      print('❌ Login exception: ${e.toString()}');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get('/Auth/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Dashboard endpoints
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/Dashboard/stats');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    try {
      final response = await _dio.get('/Dashboard/recent-activity');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Incident endpoints
  Future<List<Map<String, dynamic>>> getIncidents() async {
    try {
      final response = await _dio.get('/incidents');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createIncident(Map<String, dynamic> incidentData) async {
    try {
      final response = await _dio.post('/incidents', data: incidentData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Shift endpoints
  Future<List<Map<String, dynamic>>> getShifts() async {
    try {
      final response = await _dio.get('/shifts');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> startShift(String shiftId) async {
    try {
      final response = await _dio.post('/shifts/$shiftId/start');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> endShift(String shiftId) async {
    try {
      final response = await _dio.post('/shifts/$shiftId/end');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Check-in endpoints
  Future<Map<String, dynamic>> checkIn({
    required String shiftId,
    required double latitude,
    required double longitude,
    String? checkpointId,
    String? notes,
    String? photoPath,
  }) async {
    try {
      final response = await _dio.post('/checkins', data: {
        'shiftId': shiftId,
        'latitude': latitude,
        'longitude': longitude,
        'checkpointId': checkpointId,
        'notes': notes,
        'photoPath': photoPath,
        'checkInType': checkpointId != null ? 'QR' : 'Manual',
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Location tracking
  Future<void> updateLocation({
    required String shiftId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    int? batteryLevel,
  }) async {
    try {
      await _dio.post('/location', data: {
        'shiftId': shiftId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'batteryLevel': batteryLevel,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 403) {
          return 'You don\'t have permission to perform this action.';
        } else if (e.response?.statusCode == 404) {
          return 'The requested resource was not found.';
        } else if (e.response?.statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return e.response?.data['message'] ?? 'An error occurred. Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
