import 'package:flutter/material.dart';

class DocumentItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String iconName;
  final String colorHex;

  const DocumentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.iconName,
    required this.colorHex,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    final iconName = json['icon']?.toString() ?? 'description';
    final colorHex = json['color']?.toString() ?? '#176FF2';
    return DocumentItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: _iconFromName(iconName),
      color: _colorFromHex(colorHex),
      iconName: iconName,
      colorHex: colorHex,
    );
  }

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'assignment':
        return Icons.assignment;
      case 'verified_user':
        return Icons.verified_user;
      case 'flight_takeoff':
        return Icons.flight_takeoff;
      default:
        return Icons.description;
    }
  }

  static Color _colorFromHex(String hex) {
    final normalized = hex.replaceFirst('#', '');
    final value = int.tryParse(normalized, radix: 16);
    if (value == null) return const Color(0xFF176FF2);
    if (normalized.length <= 6) return Color(0xFF000000 | value);
    return Color(value);
  }
}
