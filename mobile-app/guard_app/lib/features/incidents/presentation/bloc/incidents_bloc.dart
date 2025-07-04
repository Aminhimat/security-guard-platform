import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

part 'incidents_event.dart';
part 'incidents_state.dart';

class IncidentsBloc extends Bloc<IncidentsEvent, IncidentsState> {
  final ApiService _apiService;

  IncidentsBloc({
    required ApiService apiService,
  })  : _apiService = apiService,
        super(IncidentsInitial()) {
    on<IncidentsLoadRequested>(_onIncidentsLoadRequested);
    on<IncidentReportRequested>(_onIncidentReportRequested);
  }

  Future<void> _onIncidentsLoadRequested(
    IncidentsLoadRequested event,
    Emitter<IncidentsState> emit,
  ) async {
    emit(IncidentsLoading());
    
    try {
      // Simulate loading incidents
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock incidents data
      final incidents = [
        IncidentModel(
          id: '1',
          title: 'Suspicious Activity',
          description: 'Unknown person loitering in parking area',
          location: 'Parking Lot B',
          priority: IncidentPriority.medium,
          status: IncidentStatus.open,
          reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
          reportedBy: 'John Doe',
        ),
        IncidentModel(
          id: '2',
          title: 'Equipment Malfunction',
          description: 'Security camera in hallway not working',
          location: 'Building A - Floor 2',
          priority: IncidentPriority.low,
          status: IncidentStatus.resolved,
          reportedAt: DateTime.now().subtract(const Duration(days: 1)),
          reportedBy: 'Jane Smith',
        ),
      ];

      emit(IncidentsLoaded(incidents: incidents));
    } catch (e) {
      emit(IncidentsError('Failed to load incidents: ${e.toString()}'));
    }
  }

  Future<void> _onIncidentReportRequested(
    IncidentReportRequested event,
    Emitter<IncidentsState> emit,
  ) async {
    try {
      // Simulate reporting incident
      await Future.delayed(const Duration(seconds: 2));
      
      // Add new incident and reload
      add(IncidentsLoadRequested());
    } catch (e) {
      emit(IncidentsError('Failed to report incident: ${e.toString()}'));
    }
  }
}
