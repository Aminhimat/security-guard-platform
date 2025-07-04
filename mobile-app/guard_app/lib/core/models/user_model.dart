class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? employeeId;
  final String? tenantId;
  final String? tenantName;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.employeeId,
    this.tenantId,
    this.tenantName,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle flexible name format from API
    String firstName = '';
    String lastName = '';
    
    if (json.containsKey('firstName') && json.containsKey('lastName')) {
      firstName = json['firstName'] as String? ?? '';
      lastName = json['lastName'] as String? ?? '';
    } else if (json.containsKey('name')) {
      final nameParts = (json['name'] as String? ?? '').split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : '';
      lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    }
    
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: firstName,
      lastName: lastName,
      role: json['role'] as String,
      employeeId: json['employeeId'] as String?,
      tenantId: json['tenantId'] as String?,
      tenantName: json['tenantName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'employeeId': employeeId,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  bool get isGuard => role.toLowerCase() == 'guard';
  bool get isSupervisor => role.toLowerCase() == 'supervisor';
  bool get isCompanyAdmin => role.toLowerCase() == 'companyadmin';
  bool get isPlatformOwner => role.toLowerCase() == 'platformowner';

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? employeeId,
    String? tenantId,
    String? tenantName,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
