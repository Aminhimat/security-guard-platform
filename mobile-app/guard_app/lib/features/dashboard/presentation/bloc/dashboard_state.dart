part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<ActivityItem> recentActivities;
  final bool isOnShift;

  const DashboardLoaded({
    required this.stats,
    required this.recentActivities,
    required this.isOnShift,
  });

  @override
  List<Object?> get props => [
        stats,
        recentActivities,
        isOnShift,
      ];

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<ActivityItem>? recentActivities,
    bool? isOnShift,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      recentActivities: recentActivities ?? this.recentActivities,
      isOnShift: isOnShift ?? this.isOnShift,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}

class DashboardStats extends Equatable {
  final int activeShifts;
  final int todayCheckIns;
  final int pendingIncidents;
  final int totalSites;

  const DashboardStats({
    required this.activeShifts,
    required this.todayCheckIns,
    required this.pendingIncidents,
    required this.totalSites,
  });

  @override
  List<Object> get props => [
        activeShifts,
        todayCheckIns,
        pendingIncidents,
        totalSites,
      ];

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      activeShifts: json['activeShifts'] ?? 0,
      todayCheckIns: json['todayCheckIns'] ?? 0,
      pendingIncidents: json['pendingIncidents'] ?? 0,
      totalSites: json['totalSites'] ?? 0,
    );
  }
}

class ActivityItem extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final DateTime timestamp;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object> get props => [
        id,
        title,
        subtitle,
        type,
        timestamp,
      ];

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      type: json['type'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
