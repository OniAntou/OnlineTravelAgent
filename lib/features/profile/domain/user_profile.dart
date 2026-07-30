class UserProfile {
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;

  const UserProfile({
    required this.name,
    required this.email,
    this.role = 'USER',
    this.phone,
    this.address,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString().toUpperCase() ?? 'USER',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
    );
  }

  bool get isPartner => role == 'PARTNER' || role == 'ADMIN';

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'role': role,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      };
}
