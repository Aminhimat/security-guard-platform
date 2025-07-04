part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {}

class DashboardRefreshRequested extends DashboardEvent {}

class DashboardShiftStatusChanged extends DashboardEvent {
  final bool isOnDuty;

  const DashboardShiftStatusChanged(this.isOnDuty);

  @override
  List<Object> get props => [isOnDuty];
}
