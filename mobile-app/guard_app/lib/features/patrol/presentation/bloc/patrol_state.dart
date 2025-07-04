part of 'patrol_bloc.dart';

abstract class PatrolState extends Equatable {
  const PatrolState();

  @override
  List<Object?> get props => [];
}

class PatrolInitial extends PatrolState {}

class PatrolLoading extends PatrolState {}

class PatrolLoaded extends PatrolState {
  final PatrolModel? currentPatrol;
  final List<CheckpointModel> checkpoints;

  const PatrolLoaded({
    this.currentPatrol,
    required this.checkpoints,
  });

  @override
  List<Object?> get props => [currentPatrol, checkpoints];

  PatrolLoaded copyWith({
    PatrolModel? currentPatrol,
    List<CheckpointModel>? checkpoints,
  }) {
    return PatrolLoaded(
      currentPatrol: currentPatrol ?? this.currentPatrol,
      checkpoints: checkpoints ?? this.checkpoints,
    );
  }
}

class PatrolError extends PatrolState {
  final String message;

  const PatrolError(this.message);

  @override
  List<Object> get props => [message];
}

class PatrolModel {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<CheckpointModel> checkpoints;
  final bool isActive;

  PatrolModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.checkpoints,
    required this.isActive,
  });

  PatrolModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    List<CheckpointModel>? checkpoints,
    bool? isActive,
  }) {
    return PatrolModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      checkpoints: checkpoints ?? this.checkpoints,
      isActive: isActive ?? this.isActive,
    );
  }

  Duration get duration {
    final endTime = this.endTime ?? DateTime.now();
    return endTime.difference(startTime);
  }

  int get completedCheckpoints {
    return checkpoints.where((c) => c.isCompleted).length;
  }

  double get completionPercentage {
    if (checkpoints.isEmpty) return 0;
    return (completedCheckpoints / checkpoints.length) * 100;
  }
}

class CheckpointModel {
  final String id;
  final String name;
  final String location;
  final String qrCode;
  final bool isCompleted;
  final DateTime? completedAt;

  CheckpointModel({
    required this.id,
    required this.name,
    required this.location,
    required this.qrCode,
    required this.isCompleted,
    this.completedAt,
  });

  CheckpointModel copyWith({
    String? id,
    String? name,
    String? location,
    String? qrCode,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return CheckpointModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      qrCode: qrCode ?? this.qrCode,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory CheckpointModel.fromJson(Map<String, dynamic> json) {
    return CheckpointModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      qrCode: json['qrCode'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }
}
