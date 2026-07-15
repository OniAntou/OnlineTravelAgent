import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/api_provider.dart';

ImageProvider<Object> resolveAppImageProvider(
  String imagePath, {
  required String baseUrl,
}) {
  final normalized = imagePath.trim();
  if (normalized.startsWith('https://') || normalized.startsWith('http://')) {
    return NetworkImage(normalized);
  }
  if (normalized.startsWith('/')) {
    return NetworkImage('$baseUrl$normalized');
  }
  return AssetImage(normalized);
}

class AppImage extends ConsumerWidget {
  const AppImage(
    this.imagePath, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.medium,
    this.errorBuilder,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int? cacheWidth;
  final int? cacheHeight;
  final FilterQuality filterQuality;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseUrl = ref.watch(apiProvider).baseUrl;
    final provider = ResizeImage.resizeIfNeeded(
      cacheWidth,
      cacheHeight,
      resolveAppImageProvider(imagePath, baseUrl: baseUrl),
    );
    return Image(
      image: provider,
      width: width,
      height: height,
      fit: fit,
      filterQuality: filterQuality,
      errorBuilder: errorBuilder,
    );
  }
}
