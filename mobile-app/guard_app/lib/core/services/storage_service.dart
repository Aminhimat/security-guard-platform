import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Auth token management
  Future<void> saveAuthToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  String? getAuthToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> removeAuthToken() async {
    await _prefs.remove('auth_token');
  }

  // User data management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString('user_data', jsonEncode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final userData = _prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> removeUserData() async {
    await _prefs.remove('user_data');
  }

  // App settings
  Future<void> setLocationPermissionGranted(bool granted) async {
    await _prefs.setBool('location_permission_granted', granted);
  }

  bool getLocationPermissionGranted() {
    return _prefs.getBool('location_permission_granted') ?? false;
  }

  Future<void> setCameraPermissionGranted(bool granted) async {
    await _prefs.setBool('camera_permission_granted', granted);
  }

  bool getCameraPermissionGranted() {
    return _prefs.getBool('camera_permission_granted') ?? false;
  }

  // Offline data management
  Future<void> saveOfflineCheckIns(List<Map<String, dynamic>> checkIns) async {
    await _prefs.setString('offline_checkins', jsonEncode(checkIns));
  }

  List<Map<String, dynamic>> getOfflineCheckIns() {
    final checkIns = _prefs.getString('offline_checkins');
    if (checkIns != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(checkIns));
    }
    return [];
  }

  Future<void> clearOfflineCheckIns() async {
    await _prefs.remove('offline_checkins');
  }

  // App preferences
  Future<void> setAutoLocationUpdate(bool enabled) async {
    await _prefs.setBool('auto_location_update', enabled);
  }

  bool getAutoLocationUpdate() {
    return _prefs.getBool('auto_location_update') ?? true;
  }

  Future<void> setLocationUpdateInterval(int minutes) async {
    await _prefs.setInt('location_update_interval', minutes);
  }

  int getLocationUpdateInterval() {
    return _prefs.getInt('location_update_interval') ?? 5; // Default 5 minutes
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
