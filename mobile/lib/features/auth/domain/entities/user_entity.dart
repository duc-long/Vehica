class UserEntity {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String? avatarUrl;
  final String role; // 'USER' | 'ADMIN'
  final String status; // 'ACTIVE' | 'BLOCKED'

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    this.avatarUrl,
    required this.role,
    required this.status,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isBlocked => status.toUpperCase() == 'BLOCKED';
}
