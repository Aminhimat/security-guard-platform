import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Update location when user moves 10 meters
  );

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status == PermissionStatus.granted;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        throw Exception('Location services are disabled.');
      }

      // Check location permission
      if (!await isLocationPermissionGranted()) {
        final granted = await requestLocationPermission();
        if (!granted) {
          throw Exception('Location permission denied.');
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  bool isWithinGeofence({
    required double userLatitude,
    required double userLongitude,
    required double centerLatitude,
    required double centerLongitude,
    required double radiusInMeters,
  }) {
    final distance = calculateDistance(
      userLatitude,
      userLongitude,
      centerLatitude,
      centerLongitude,
    );
    return distance <= radiusInMeters;
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
