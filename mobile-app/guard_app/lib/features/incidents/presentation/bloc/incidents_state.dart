part of 'incidents_bloc.dart';

abstract class IncidentsState extends Equatable {
  const IncidentsState();

  @override
  List<Object> get props => [];
}

class IncidentsInitial extends IncidentsState {}

class IncidentsLoading extends IncidentsState {}

class IncidentsLoaded extends IncidentsState {
  final List<IncidentModel> incidents;

  const IncidentsLoaded({required this.incidents});

  @override
  List<Object> get props => [incidents];
}

class IncidentsError extends IncidentsState {
  final String message;

  const IncidentsError(this.message);

  @override
  List<Object> get props => [message];
}

enum IncidentPriority { low, medium, high, critical }

enum IncidentStatus { open, inProgress, resolved, closed }

class IncidentModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final IncidentPriority priority;
  final IncidentStatus status;
  final DateTime reportedAt;
  final String reportedBy;
  final List<String>? attachments;

  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.priority,
    required this.status,
    required this.reportedAt,
    required this.reportedBy,
    this.attachments,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      priority: IncidentPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => IncidentPriority.medium,
      ),
      status: IncidentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IncidentStatus.open,
      ),
      reportedAt: DateTime.parse(json['reportedAt'] ?? DateTime.now().toIso8601String()),
      reportedBy: json['reportedBy'] ?? '',
      attachments: json['attachments']?.cast<String>(),
    );
  }
}
