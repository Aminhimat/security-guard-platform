import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://security-guard-platform.fly.dev/api';
  String? _token;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // Authentication APIs
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return LoginResponse.fromJson(data);
      } else {
        throw ApiException('Login failed: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
  }

  // Management APIs
  Future<List<GuardInfo>> getGuards() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/management/guards'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => GuardInfo.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to get guards: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<List<PatrolRecord>> getPatrols({DateTime? date}) async {
    try {
      String url = '$baseUrl/management/patrols';
      if (date != null) {
        url += '?date=${date.toIso8601String()}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PatrolRecord.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to get patrols: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<List<IncidentInfo>> getIncidents({DateTime? date}) async {
    try {
      String url = '$baseUrl/management/incidents';
      if (date != null) {
        url += '?date=${date.toIso8601String()}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => IncidentInfo.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to get incidents: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<ManagementStats> getManagementStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/management/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ManagementStats.fromJson(data);
      } else {
        throw ApiException('Failed to get stats: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Guard APIs
  Future<CheckInResponse> checkIn({
    required double latitude,
    required double longitude,
    String? notes,
    String? checkpointId,
    String? siteId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guard/checkin'),
        headers: _headers,
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'notes': notes,
          'checkpointId': checkpointId,
          'siteId': siteId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CheckInResponse.fromJson(data);
      } else {
        throw ApiException('Check-in failed: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<IncidentResponse> reportIncident({
    required String type,
    required String severity,
    required String description,
    required double latitude,
    required double longitude,
    String? siteId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guard/incident'),
        headers: _headers,
        body: jsonEncode({
          'type': type,
          'severity': severity,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'siteId': siteId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return IncidentResponse.fromJson(data);
      } else {
        throw ApiException('Incident report failed: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<CurrentShift> getCurrentShift() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/guard/shifts/current'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CurrentShift.fromJson(data);
      } else {
        throw ApiException('Failed to get current shift: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<ShiftResponse> startShift({String? siteId, String? notes}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guard/shifts/start'),
        headers: _headers,
        body: jsonEncode({
          'siteId': siteId,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShiftResponse.fromJson(data);
      } else {
        throw ApiException('Failed to start shift: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<ShiftResponse> endShift({String? notes}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guard/shifts/end'),
        headers: _headers,
        body: jsonEncode({
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShiftResponse.fromJson(data);
      } else {
        throw ApiException('Failed to end shift: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<List<PatrolHistory>> getPatrolHistory({int days = 7}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/guard/patrols/history?days=$days'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PatrolHistory.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to get patrol history: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
}

// Exception class
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}

// Data Models
class LoginResponse {
  final String token;
  final String refreshToken;
  final UserDto user;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      user: UserDto.fromJson(json['user']),
    );
  }
}

class UserDto {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? employeeId;
  final String? tenantId;
  final String? tenantName;
  final bool isActive;
  final DateTime createdAt;

  UserDto({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.employeeId,
    this.tenantId,
    this.tenantName,
    required this.isActive,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
      employeeId: json['employeeId'],
      tenantId: json['tenantId'],
      tenantName: json['tenantName'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class GuardInfo {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;

  GuardInfo({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
  });

  factory GuardInfo.fromJson(Map<String, dynamic> json) {
    return GuardInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      isActive: json['isActive'],
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class PatrolRecord {
  final String id;
  final String guardId;
  final String guardName;
  final DateTime timestamp;
  final String location;
  final double latitude;
  final double longitude;
  final String notes;
  final List<String> photos;
  final String status;

  PatrolRecord({
    required this.id,
    required this.guardId,
    required this.guardName,
    required this.timestamp,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.notes,
    required this.photos,
    required this.status,
  });

  factory PatrolRecord.fromJson(Map<String, dynamic> json) {
    return PatrolRecord(
      id: json['id'],
      guardId: json['guardId'],
      guardName: json['guardName'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      notes: json['notes'],
      photos: List<String>.from(json['photos']),
      status: json['status'],
    );
  }
}

class IncidentInfo {
  final String id;
  final String guardId;
  final String guardName;
  final DateTime timestamp;
  final String location;
  final double latitude;
  final double longitude;
  final String type;
  final String severity;
  final String description;
  final String status;
  final List<String> photos;

  IncidentInfo({
    required this.id,
    required this.guardId,
    required this.guardName,
    required this.timestamp,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.severity,
    required this.description,
    required this.status,
    required this.photos,
  });

  factory IncidentInfo.fromJson(Map<String, dynamic> json) {
    return IncidentInfo(
      id: json['id'],
      guardId: json['guardId'],
      guardName: json['guardName'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      type: json['type'],
      severity: json['severity'],
      description: json['description'],
      status: json['status'],
      photos: List<String>.from(json['photos']),
    );
  }
}

class ManagementStats {
  final int totalGuards;
  final int onDutyGuards;
  final int todayPatrols;
  final int todayIncidents;
  final int pendingIncidents;

  ManagementStats({
    required this.totalGuards,
    required this.onDutyGuards,
    required this.todayPatrols,
    required this.todayIncidents,
    required this.pendingIncidents,
  });

  factory ManagementStats.fromJson(Map<String, dynamic> json) {
    return ManagementStats(
      totalGuards: json['totalGuards'],
      onDutyGuards: json['onDutyGuards'],
      todayPatrols: json['todayPatrols'],
      todayIncidents: json['todayIncidents'],
      pendingIncidents: json['pendingIncidents'],
    );
  }
}

class CheckInResponse {
  final String id;
  final DateTime checkInTime;
  final bool success;
  final String message;

  CheckInResponse({
    required this.id,
    required this.checkInTime,
    required this.success,
    required this.message,
  });

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      id: json['id'],
      checkInTime: DateTime.parse(json['checkInTime']),
      success: json['success'],
      message: json['message'],
    );
  }
}

class IncidentResponse {
  final String id;
  final DateTime reportedAt;
  final bool success;
  final String message;

  IncidentResponse({
    required this.id,
    required this.reportedAt,
    required this.success,
    required this.message,
  });

  factory IncidentResponse.fromJson(Map<String, dynamic> json) {
    return IncidentResponse(
      id: json['id'],
      reportedAt: DateTime.parse(json['reportedAt']),
      success: json['success'],
      message: json['message'],
    );
  }
}

class CurrentShift {
  final bool isOnDuty;
  final String? shiftId;
  final DateTime? startTime;
  final String? siteName;
  final String? siteId;

  CurrentShift({
    required this.isOnDuty,
    this.shiftId,
    this.startTime,
    this.siteName,
    this.siteId,
  });

  factory CurrentShift.fromJson(Map<String, dynamic> json) {
    return CurrentShift(
      isOnDuty: json['isOnDuty'],
      shiftId: json['shiftId'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      siteName: json['siteName'],
      siteId: json['siteId'],
    );
  }
}

class ShiftResponse {
  final String id;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool success;
  final String message;

  ShiftResponse({
    required this.id,
    this.startTime,
    this.endTime,
    required this.success,
    required this.message,
  });

  factory ShiftResponse.fromJson(Map<String, dynamic> json) {
    return ShiftResponse(
      id: json['id'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      success: json['success'],
      message: json['message'],
    );
  }
}

class PatrolHistory {
  final String id;
  final DateTime timestamp;
  final String location;
  final String? checkpointName;
  final double latitude;
  final double longitude;
  final String notes;
  final String status;

  PatrolHistory({
    required this.id,
    required this.timestamp,
    required this.location,
    this.checkpointName,
    required this.latitude,
    required this.longitude,
    required this.notes,
    required this.status,
  });

  factory PatrolHistory.fromJson(Map<String, dynamic> json) {
    return PatrolHistory(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
      checkpointName: json['checkpointName'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      notes: json['notes'],
      status: json['status'],
    );
  }
}
