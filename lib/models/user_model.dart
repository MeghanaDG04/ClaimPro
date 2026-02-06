import 'package:uuid/uuid.dart';

enum UserRole {
  admin,
  user,
  viewer,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.user:
        return 'User';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  String toApiValue() {
    return name.toUpperCase();
  }

  static UserRole fromApiValue(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => UserRole.viewer,
    );
  }

  bool get canCreate => this == UserRole.admin || this == UserRole.user;
  bool get canEdit => this == UserRole.admin || this == UserRole.user;
  bool get canDelete => this == UserRole.admin;
  bool get canApprove => this == UserRole.admin;
  bool get canManageUsers => this == UserRole.admin;
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final String? department;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.department,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.create({
    required String email,
    required String name,
    required UserRole role,
    String? phone,
    String? department,
  }) {
    return UserModel(
      id: const Uuid().v4(),
      email: email,
      name: name,
      role: role,
      phone: phone,
      department: department,
      createdAt: DateTime.now(),
      lastLoginAt: null,
    );
  }

  factory UserModel.empty() {
    return UserModel(
      id: const Uuid().v4(),
      email: '',
      name: '',
      role: UserRole.viewer,
      phone: null,
      department: null,
      createdAt: DateTime.now(),
      lastLoginAt: null,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? phone,
    String? department,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toApiValue(),
      'phone': phone,
      'department': department,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRoleExtension.fromApiValue(json['role'] as String),
      phone: json['phone'] as String?,
      department: json['department'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, role: ${role.displayName})';
  }
}
