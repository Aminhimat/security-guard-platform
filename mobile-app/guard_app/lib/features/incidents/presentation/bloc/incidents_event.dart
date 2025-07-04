part of 'incidents_bloc.dart';

abstract class IncidentsEvent extends Equatable {
  const IncidentsEvent();

  @override
  List<Object> get props => [];
}

class IncidentsLoadRequested extends IncidentsEvent {}

class IncidentReportRequested extends IncidentsEvent {
  final String title;
  final String description;
  final String location;
  final IncidentPriority priority;

  const IncidentReportRequested({
    required this.title,
    required this.description,
    required this.location,
    required this.priority,
  });

  @override
  List<Object> get props => [title, description, location, priority];
}
