import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/shared/widgets/app_image.dart';

void main() {
  test(
    'resolves bundled assets and uploaded media through distinct providers',
    () {
      final asset = resolveAppImageProvider(
        'assets/images/dalat.jpg',
        baseUrl: 'https://api.example.com',
      );
      final uploaded = resolveAppImageProvider(
        '/uploads/dalat.jpg',
        baseUrl: 'https://api.example.com',
      );
      final absolute = resolveAppImageProvider(
        'https://cdn.example.com/dalat.jpg',
        baseUrl: 'https://api.example.com',
      );

      expect(asset, isA<AssetImage>());
      expect(
        (uploaded as NetworkImage).url,
        'https://api.example.com/uploads/dalat.jpg',
      );
      expect(
        (absolute as NetworkImage).url,
        'https://cdn.example.com/dalat.jpg',
      );
    },
  );
}
