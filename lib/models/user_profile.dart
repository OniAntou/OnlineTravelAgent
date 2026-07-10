class UserProfile {
  final String name;
  final String email;
  final String role;

  const UserProfile({
    required this.name,
    required this.email,
    this.role = 'USER',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString().toUpperCase() ?? 'USER',
    );
  }

  bool get isPartner => role == 'PARTNER' || role == 'ADMIN';

  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'role': role};
}
