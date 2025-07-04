import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ApiService _apiService;

  DashboardBloc({
    required ApiService apiService,
  })  : _apiService = apiService,
        super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onDashboardLoadRequested);
    on<DashboardRefreshRequested>(_onDashboardRefreshRequested);
    on<DashboardShiftStatusChanged>(_onDashboardShiftStatusChanged);
  }

  Future<void> _onDashboardLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    
    try {
      // Fetch real dashboard data from API
      final stats = await _apiService.getDashboardStats();
      final recentActivity = await _apiService.getRecentActivity();
      
      // Convert API data to UI models
      final activities = recentActivity.map((activity) => ActivityItem(
        id: activity['id'],
        title: activity['description'],
        subtitle: activity['type'],
        type: activity['type'],
        timestamp: DateTime.parse(activity['timestamp']),
      )).toList();

      emit(DashboardLoaded(
        stats: DashboardStats(
          activeShifts: stats['activeShifts'] ?? 0,
          todayCheckIns: stats['todayCheckIns'] ?? 0,
          pendingIncidents: stats['pendingIncidents'] ?? 0,
          totalSites: stats['totalSites'] ?? 0,
        ),
        recentActivities: activities,
        isOnShift: stats['activeShifts'] > 0,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard: ${e.toString()}'));
    }
  }

  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Reload dashboard data
    add(DashboardLoadRequested());
  }

  Future<void> _onDashboardShiftStatusChanged(
    DashboardShiftStatusChanged event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(
        isOnShift: event.isOnDuty,
      ));
    }
  }
}
