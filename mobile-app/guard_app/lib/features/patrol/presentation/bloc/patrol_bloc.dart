import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/location_service.dart';

part 'patrol_event.dart';
part 'patrol_state.dart';

class PatrolBloc extends Bloc<PatrolEvent, PatrolState> {
  final ApiService _apiService;
  final LocationService _locationService;

  PatrolBloc({
    required ApiService apiService,
    required LocationService locationService,
  })  : _apiService = apiService,
        _locationService = locationService,
        super(PatrolInitial()) {
    on<PatrolLoadRequested>(_onPatrolLoadRequested);
    on<PatrolStartRequested>(_onPatrolStartRequested);
    on<PatrolEndRequested>(_onPatrolEndRequested);
    on<CheckpointScanRequested>(_onCheckpointScanRequested);
  }

  Future<void> _onPatrolLoadRequested(
    PatrolLoadRequested event,
    Emitter<PatrolState> emit,
  ) async {
    emit(PatrolLoading());
    
    try {
      // Simulate loading patrol data
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock patrol data
      final checkpoints = [
        CheckpointModel(
          id: '1',
          name: 'Main Entrance',
          location: 'Building A - Entrance',
          qrCode: 'CHECKPOINT_MAIN_001',
          isCompleted: true,
          completedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        CheckpointModel(
          id: '2',
          name: 'Parking Area',
          location: 'Parking Lot B',
          qrCode: 'CHECKPOINT_PARK_002',
          isCompleted: true,
          completedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        CheckpointModel(
          id: '3',
          name: 'Emergency Exit',
          location: 'Building C - Rear',
          qrCode: 'CHECKPOINT_EXIT_003',
          isCompleted: false,
        ),
        CheckpointModel(
          id: '4',
          name: 'Security Office',
          location: 'Building A - Floor 1',
          qrCode: 'CHECKPOINT_OFFICE_004',
          isCompleted: false,
        ),
      ];

      final currentPatrol = PatrolModel(
        id: '1',
        startTime: DateTime.now().subtract(const Duration(hours: 3)),
        checkpoints: checkpoints,
        isActive: true,
      );

      emit(PatrolLoaded(
        currentPatrol: currentPatrol,
        checkpoints: checkpoints,
      ));
    } catch (e) {
      emit(PatrolError('Failed to load patrol data: ${e.toString()}'));
    }
  }

  Future<void> _onPatrolStartRequested(
    PatrolStartRequested event,
    Emitter<PatrolState> emit,
  ) async {
    if (state is PatrolLoaded) {
      final currentState = state as PatrolLoaded;
      
      // Create new patrol
      final newPatrol = PatrolModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        checkpoints: currentState.checkpoints,
        isActive: true,
      );

      emit(currentState.copyWith(
        currentPatrol: newPatrol,
      ));
    }
  }

  Future<void> _onPatrolEndRequested(
    PatrolEndRequested event,
    Emitter<PatrolState> emit,
  ) async {
    if (state is PatrolLoaded) {
      final currentState = state as PatrolLoaded;
      
      if (currentState.currentPatrol != null) {
        final endedPatrol = currentState.currentPatrol!.copyWith(
          endTime: DateTime.now(),
          isActive: false,
        );

        emit(currentState.copyWith(
          currentPatrol: endedPatrol,
        ));
      }
    }
  }

  Future<void> _onCheckpointScanRequested(
    CheckpointScanRequested event,
    Emitter<PatrolState> emit,
  ) async {
    if (state is PatrolLoaded) {
      final currentState = state as PatrolLoaded;
      
      // Find and update the checkpoint
      final updatedCheckpoints = currentState.checkpoints.map((checkpoint) {
        if (checkpoint.qrCode == event.qrCode) {
          return checkpoint.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
        }
        return checkpoint;
      }).toList();

      emit(currentState.copyWith(
        checkpoints: updatedCheckpoints,
        currentPatrol: currentState.currentPatrol?.copyWith(
          checkpoints: updatedCheckpoints,
        ),
      ));
    }
  }
}
