part of 'patrol_bloc.dart';

abstract class PatrolEvent extends Equatable {
  const PatrolEvent();

  @override
  List<Object> get props => [];
}

class PatrolLoadRequested extends PatrolEvent {}

class PatrolStartRequested extends PatrolEvent {}

class PatrolEndRequested extends PatrolEvent {}

class CheckpointScanRequested extends PatrolEvent {
  final String qrCode;

  const CheckpointScanRequested(this.qrCode);

  @override
  List<Object> get props => [qrCode];
}
