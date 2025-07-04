import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/storage_service.dart';
import 'dart:async';

// Events
abstract class LocationEvent {}

class StartLocationTrackingEvent extends LocationEvent {
  final String shiftId;
  StartLocationTrackingEvent({required this.shiftId});
}

class StopLocationTrackingEvent extends LocationEvent {}

class LocationUpdateEvent extends LocationEvent {
  final Position position;
  LocationUpdateEvent({required this.position});
}

class RequestLocationPermissionEvent extends LocationEvent {}

// States
abstract class LocationState {}

class LocationInitialState extends LocationState {}

class LocationPermissionDeniedState extends LocationState {}

class LocationServiceDisabledState extends LocationState {}

class LocationTrackingState extends LocationState {
  final Position currentPosition;
  final bool isTracking;
  final String? shiftId;

  LocationTrackingState({
    required this.currentPosition,
    required this.isTracking,
    this.shiftId,
  });
}

class LocationErrorState extends LocationState {
  final String message;
  LocationErrorState({required this.message});
}

class LocationLoadingState extends LocationState {}

// BLoC
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final ApiService apiService;
  final LocationService locationService;
  final StorageService storageService;
  
  StreamSubscription<Position>? _locationSubscription;
  Timer? _updateTimer;
  String? _currentShiftId;

  LocationBloc({
    required this.apiService,
    required this.locationService,
    required this.storageService,
  }) : super(LocationInitialState()) {
    on<StartLocationTrackingEvent>(_onStartLocationTracking);
    on<StopLocationTrackingEvent>(_onStopLocationTracking);
    on<LocationUpdateEvent>(_onLocationUpdate);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _updateTimer?.cancel();
    return super.close();
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermissionEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoadingState());

    try {
      final hasPermission = await locationService.requestLocationPermission();
      if (!hasPermission) {
        emit(LocationPermissionDeniedState());
        return;
      }

      final isServiceEnabled = await locationService.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        emit(LocationServiceDisabledState());
        return;
      }

      // Get current location to verify everything works
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        emit(LocationTrackingState(
          currentPosition: position,
          isTracking: false,
        ));
      } else {
        emit(LocationErrorState(message: 'Unable to get current location'));
      }
    } catch (e) {
      emit(LocationErrorState(message: e.toString()));
    }
  }

  Future<void> _onStartLocationTracking(
    StartLocationTrackingEvent event,
    Emitter<LocationState> emit,
  ) async {
    try {
      _currentShiftId = event.shiftId;

      // Check permissions first
      if (!await locationService.isLocationPermissionGranted()) {
        emit(LocationPermissionDeniedState());
        return;
      }

      if (!await locationService.isLocationServiceEnabled()) {
        emit(LocationServiceDisabledState());
        return;
      }

      // Get initial position
      final initialPosition = await locationService.getCurrentLocation();
      if (initialPosition == null) {
        emit(LocationErrorState(message: 'Unable to get initial location'));
        return;
      }

      // Start listening to location updates
      _locationSubscription = locationService.getLocationStream().listen(
        (position) => add(LocationUpdateEvent(position: position)),
        onError: (error) => emit(LocationErrorState(message: error.toString())),
      );

      // Set up periodic API updates (every 5 minutes)
      _updateTimer = Timer.periodic(
        Duration(minutes: storageService.getLocationUpdateInterval()),
        (_) => _sendLocationToServer(initialPosition),
      );

      emit(LocationTrackingState(
        currentPosition: initialPosition,
        isTracking: true,
        shiftId: event.shiftId,
      ));

      // Send initial location
      await _sendLocationToServer(initialPosition);
    } catch (e) {
      emit(LocationErrorState(message: e.toString()));
    }
  }

  Future<void> _onStopLocationTracking(
    StopLocationTrackingEvent event,
    Emitter<LocationState> emit,
  ) async {
    _locationSubscription?.cancel();
    _updateTimer?.cancel();
    _currentShiftId = null;

    if (state is LocationTrackingState) {
      final currentState = state as LocationTrackingState;
      emit(LocationTrackingState(
        currentPosition: currentState.currentPosition,
        isTracking: false,
      ));
    }
  }

  Future<void> _onLocationUpdate(
    LocationUpdateEvent event,
    Emitter<LocationState> emit,
  ) async {
    if (state is LocationTrackingState) {
      final currentState = state as LocationTrackingState;
      emit(LocationTrackingState(
        currentPosition: event.position,
        isTracking: currentState.isTracking,
        shiftId: currentState.shiftId,
      ));
    }
  }

  Future<void> _sendLocationToServer(Position position) async {
    if (_currentShiftId == null) return;

    try {
      await apiService.updateLocation(
        shiftId: _currentShiftId!,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        // batteryLevel: await _getBatteryLevel(), // TODO: Implement battery level
      );
    } catch (e) {
      print('Failed to send location to server: $e');
      // TODO: Store offline for later sync
    }
  }
}
