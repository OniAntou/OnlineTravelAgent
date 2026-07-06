import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background while loading images
      body: Stack(
        children: [
          // 1. Background Image Layer
          const Positioned.fill(child: _BackgroundSlider()),

          // 2. Gradient Overlay Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),

          // 3. UI Content Layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  const Center(child: _VietnamTextAnimation()),
                  const Spacer(),
                  Text(
                    tr('welcome.enjoy'),
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  Text(
                    tr('welcome.vacation'),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    tr('welcome.dream'),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Button at the bottom
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/main');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        tr('welcome.explore'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // Padding from bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundSlider extends StatefulWidget {
  const _BackgroundSlider();

  @override
  State<_BackgroundSlider> createState() => _BackgroundSliderState();
}

class _BackgroundSliderState extends State<_BackgroundSlider> {
  final List<String> images = const [
    'assets/images/dalat_image.jpg',
    'assets/images/phuquoc_image.jpg',
    'assets/images/hoian_image.webp',
  ];
  int currentImageIndex = 0;
  Timer? timer;
  bool _didPrecache = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          currentImageIndex = (currentImageIndex + 1) % images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) {
      return;
    }
    for (final image in images) {
      precacheImage(AssetImage(image), context);
    }
    _didPrecache = true;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      child: Image.asset(
        images[currentImageIndex],
        key: ValueKey<int>(currentImageIndex),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: \$error');
          return const ColoredBox(color: Colors.blueGrey);
        },
      ),
    );
  }
}

class _VietnamTextAnimation extends StatefulWidget {
  const _VietnamTextAnimation();

  @override
  State<_VietnamTextAnimation> createState() => _VietnamTextAnimationState();
}

class _VietnamTextAnimationState extends State<_VietnamTextAnimation>
    with SingleTickerProviderStateMixin {
  late final List<Path> _vietnamPaths;
  late final AnimationController _controller;
  late final Animation<double> _progress;
  bool _showFill = false;
  Timer? _vietnamTextTimer;

  @override
  void initState() {
    super.initState();
    _vietnamPaths = [
      parseSvgPathData(
        'M18.48 88.62L18.48 88.62Q17.25 88.62 15.44 88.04Q13.64 87.47 12.28 85.98Q10.91 84.48 10.91 81.58L10.91 81.58Q10.91 79.02 12.01 74.89Q13.11 70.75 14.78 65.60Q16.46 60.46 18.13 54.78Q19.80 49.10 20.90 43.38Q22 37.66 22 32.38L22 32.38Q22 29.13 21.78 26.31Q21.56 23.50 20.46 21.78Q19.36 20.06 16.72 20.06L16.72 20.06Q14.26 20.06 12.54 21.52Q10.82 22.97 9.72 25.26Q8.62 27.54 8.14 30.10Q7.66 32.65 7.66 34.85L7.66 34.85Q7.66 36.26 7.88 37.44Q8.10 38.63 8.45 39.60L8.45 39.60Q5.02 39.60 3.61 37.71Q2.20 35.82 2.20 33.26L2.20 33.26Q2.20 30.54 3.48 27.81Q4.75 25.08 7.00 22.75Q9.24 20.42 12.14 19.01Q15.05 17.60 18.30 17.60L18.30 17.60Q23.76 17.60 26.44 21.87Q29.13 26.14 29.13 33.26L29.13 33.26Q29.13 38.37 27.98 43.96Q26.84 49.54 25.17 55.09Q23.50 60.63 21.78 65.74Q20.06 70.84 18.92 75.15Q17.78 79.46 17.78 82.46L17.78 82.46Q17.78 83.95 18.26 84.92Q18.74 85.89 20.24 85.89L20.24 85.89Q22.70 85.89 25.96 83.38Q29.22 80.87 32.69 76.52Q36.17 72.16 39.47 66.70Q42.77 61.25 45.41 55.31Q48.05 49.37 49.63 43.65Q51.22 37.93 51.22 33.09L51.22 33.09Q51.22 28.69 49.90 26.62Q48.58 24.55 46.38 23.94L46.38 23.94Q47.61 21.82 48.97 20.86Q50.34 19.89 51.48 19.89L51.48 19.89Q53.33 19.89 55.09 22.26Q56.85 24.64 56.85 29.66L56.85 29.66Q56.85 34.50 55.04 40.66Q53.24 46.82 50.16 53.46Q47.08 60.10 43.12 66.35Q39.16 72.60 34.85 77.62Q30.54 82.63 26.31 85.62Q22.09 88.62 18.48 88.62ZM59.75 83.25L59.75 83.25Q56.32 83.25 54.65 81.09Q52.98 78.94 52.98 75.86L52.98 75.86Q52.98 73.83 53.72 70.75Q54.47 67.67 55.70 64.28Q56.94 60.90 58.56 57.90Q60.19 54.91 62.04 53.02Q63.89 51.13 65.65 51.13L65.65 51.13Q66.44 51.13 67.01 51.61Q67.58 52.10 67.58 53.06L67.58 53.06Q67.58 54.12 66.22 56.50Q64.86 58.87 63.01 61.95Q61.16 65.03 59.80 68.42Q58.43 71.81 58.43 74.89L58.43 74.89Q58.43 78.06 59.49 79.11Q60.54 80.17 62.74 80.17L62.74 80.17Q65.74 80.17 69.12 77.18Q72.51 74.18 76.30 66.70L76.30 66.70L77.09 67.58Q74.54 75.15 69.74 79.20Q64.94 83.25 59.75 83.25ZM70.31 42.94L70.31 42.94Q68.90 42.94 67.80 42.24Q66.70 41.54 66.70 40.04L66.70 40.04Q66.70 38.19 68.86 36.83Q71.02 35.46 73.13 35.46L73.13 35.46Q74.45 35.46 75.24 36.08Q76.03 36.70 76.03 38.19L76.03 38.19Q76.03 39.86 74.23 41.40Q72.42 42.94 70.31 42.94ZM84.13 84.83L84.13 84.83Q78.76 84.83 76.08 81.88Q73.39 78.94 73.39 74.62L73.39 74.62Q73.39 70.66 75.37 66.26Q77.35 61.86 80.65 57.99Q83.95 54.12 87.91 51.70Q91.87 49.28 95.74 49.28L95.74 49.28Q97.77 49.28 99.48 50.34Q101.20 51.39 101.20 54.65L101.20 54.65Q101.20 57.99 99.22 60.94Q97.24 63.89 94.03 66.18Q90.82 68.46 86.99 69.92Q83.16 71.37 79.38 71.72L79.38 71.72Q79.20 72.60 79.11 73.39Q79.02 74.18 79.02 74.89L79.02 74.89Q79.02 76.21 79.33 77.53Q79.64 78.85 80.43 79.95Q81.22 81.05 82.59 81.66Q83.95 82.28 85.98 82.28L85.98 82.28Q89.76 82.28 93.46 80.12Q97.15 77.97 100.32 74.45Q103.49 70.93 105.69 66.70L105.69 66.70L106.74 67.50Q104.37 72.78 100.72 76.65Q97.06 80.52 92.80 82.68Q88.53 84.83 84.13 84.83ZM79.82 70.05L79.82 70.05Q82.19 69.26 85.18 67.72Q88.18 66.18 90.95 64.06Q93.72 61.95 95.52 59.40Q97.33 56.85 97.33 54.03L97.33 54.03Q97.33 53.06 96.98 52.54Q96.62 52.01 95.48 52.01L95.48 52.01Q93.37 52.01 90.99 53.64Q88.62 55.26 86.42 57.90Q84.22 60.54 82.46 63.71Q80.70 66.88 79.82 70.05ZM111.41 85.01L111.41 85.01Q107.62 85.01 105.60 82.81Q103.58 80.61 103.58 76.30L103.58 76.30Q103.58 72.42 105.03 66.75Q106.48 61.07 108.68 55.09L108.68 55.09Q107.80 54.91 107.01 54.78Q106.22 54.65 105.51 54.38L105.51 54.38L105.51 52.80Q106.22 52.89 107.18 52.98Q108.15 53.06 109.38 53.15L109.38 53.15Q111.23 48.40 113.34 43.96Q115.46 39.51 117.52 36.04Q119.59 32.56 121.48 30.49Q123.38 28.42 124.70 28.42L124.70 28.42Q125.40 28.42 125.97 28.91Q126.54 29.39 126.54 30.36L126.54 30.36Q126.54 31.86 124.70 35.24Q122.85 38.63 120.12 43.30Q117.39 47.96 114.84 53.42L114.84 53.42Q115.63 53.42 116.47 53.42Q117.30 53.42 118.10 53.42L118.10 53.42Q121 53.42 124.21 53.33Q127.42 53.24 130.68 52.89L130.68 52.89L130.68 54.47Q125.84 55 122.01 55.26Q118.18 55.53 115.19 55.53L115.19 55.53Q114.84 55.53 114.53 55.53Q114.22 55.53 113.87 55.53L113.87 55.53Q111.85 60.19 110.44 65.12Q109.03 70.05 109.03 74.71L109.03 74.71Q109.03 78.50 110.18 80.12Q111.32 81.75 113.96 81.75L113.96 81.75Q118.54 81.75 122.94 77.70Q127.34 73.66 130.68 66.70L130.68 66.70L131.82 67.58Q129.71 72.51 126.50 76.47Q123.29 80.43 119.42 82.72Q115.54 85.01 111.41 85.01ZM157.43 82.72L157.43 82.72Q154.35 82.72 152.81 81.14Q151.27 79.55 151.27 77.09L151.27 77.09Q151.27 75.24 151.93 73.22Q152.59 71.19 153.21 69.04Q153.82 66.88 153.82 64.86L153.82 64.86Q153.82 62.39 152.81 61.47Q151.80 60.54 150.30 60.54L150.30 60.54Q147.58 60.54 144.76 62.79Q141.94 65.03 139.30 68.51Q136.66 71.98 134.38 75.68Q132.09 79.38 130.33 82.28L130.33 82.28Q128.92 82.28 127.64 81.80Q126.37 81.31 125.66 80.34L125.66 80.34Q125.66 79.90 126.59 77.62Q127.51 75.33 128.74 71.98Q129.98 68.64 130.94 65.12Q131.91 61.60 131.91 58.70L131.91 58.70Q132.44 58.08 133.58 57.46Q134.73 56.85 135.96 56.85L135.96 56.85Q138.34 56.85 138.34 59.14L138.34 59.14Q138.34 60.54 137.54 63.84Q136.75 67.14 135.52 70.75L135.52 70.75Q137.90 67.14 140.84 63.58Q143.79 60.02 147.14 57.64Q150.48 55.26 153.82 55.26L153.82 55.26Q157.26 55.26 158.80 57.73Q160.34 60.19 160.34 63.18L160.34 63.18Q160.34 65.91 159.46 68.24Q158.58 70.58 157.65 72.73Q156.73 74.89 156.73 77.09L156.73 77.09Q156.73 78.94 157.48 79.68Q158.22 80.43 159.37 80.43L159.37 80.43Q161.57 80.43 163.77 78.36Q165.97 76.30 168.04 73.13Q170.10 69.96 171.69 66.70L171.69 66.70L172.66 67.85Q170.81 72.16 168.52 75.50Q166.23 78.85 163.50 80.78Q160.78 82.72 157.43 82.72ZM174.24 85.10L174.24 85.10Q171.51 85.10 169.62 83.29Q167.73 81.49 167.73 77.79L167.73 77.79Q167.73 74.62 169.14 70.97Q170.54 67.32 173.01 63.76Q175.47 60.19 178.60 57.24Q181.72 54.30 185.20 52.54Q188.67 50.78 192.10 50.78L192.10 50.78Q195.54 50.78 197.82 52.58Q200.11 54.38 200.11 57.38L200.11 57.38Q200.11 59.58 198.92 60.37Q197.74 61.16 195.80 61.16L195.80 61.16Q195.98 60.46 196.11 59.62Q196.24 58.78 196.24 58.08L196.24 58.08Q196.24 56.06 195.27 54.60Q194.30 53.15 191.93 53.15L191.93 53.15Q189.46 53.15 186.91 54.87Q184.36 56.58 181.98 59.44Q179.61 62.30 177.76 65.65Q175.91 68.99 174.86 72.25Q173.80 75.50 173.80 78.06L173.80 78.06Q173.80 81.49 176.18 81.49L176.18 81.49Q178.20 81.49 180.58 79.60Q182.95 77.70 185.46 74.76Q187.97 71.81 190.26 68.64Q192.54 65.47 194.30 62.83L194.30 62.83Q194.66 62.30 194.74 62.30L194.74 62.30Q195.27 62.39 196.11 62.66Q196.94 62.92 197.56 63.36Q198.18 63.80 198.18 64.50L198.18 64.50Q198.18 65.30 197.38 66.66Q196.59 68.02 195.62 69.78Q194.66 71.54 193.86 73.35Q193.07 75.15 193.07 76.74L193.07 76.74Q193.07 78.06 193.78 79.33Q194.48 80.61 196.06 80.61L196.06 80.61Q198.44 80.61 202.31 77.13Q206.18 73.66 210.14 66.70L210.14 66.70L211.02 67.58Q209.18 72.34 206.27 75.94Q203.37 79.55 200.07 81.58Q196.77 83.60 193.60 83.60L193.60 83.60Q190.34 83.60 188.80 81.66Q187.26 79.73 187.26 77.44L187.26 77.44Q187.26 76.91 187.35 76.25Q187.44 75.59 187.53 74.89L187.53 74.89Q183.74 79.99 180.62 82.54Q177.50 85.10 174.24 85.10ZM252.74 83.69L252.74 83.69Q249.66 83.69 248.25 81.80Q246.84 79.90 246.84 77.26L246.84 77.26Q246.84 75.06 247.50 72.86Q248.16 70.66 248.82 68.55Q249.48 66.44 249.48 64.77L249.48 64.77Q249.48 63.01 248.69 62.30Q247.90 61.60 246.93 61.60L246.93 61.60Q244.73 61.60 242.13 65.03Q239.54 68.46 235.40 74.71L235.40 74.71Q233.99 76.82 233.02 78.98Q232.06 81.14 231.18 82.90L231.18 82.90Q230.47 82.90 229.42 82.72Q228.36 82.54 227.52 82.15Q226.69 81.75 226.69 81.14L226.69 81.14Q226.69 80.52 227.52 78.19Q228.36 75.86 229.46 72.73Q230.56 69.61 231.40 66.40Q232.23 63.18 232.23 60.90L232.23 60.90Q232.23 59.40 231.75 58.48Q231.26 57.55 230.03 57.55L230.03 57.55Q228.10 57.55 225.37 59.88Q222.64 62.22 219.74 66Q216.83 69.78 214.24 74.32Q211.64 78.85 210.06 83.34L210.06 83.34Q209.26 83.34 208.12 83.07Q206.98 82.81 206.14 82.37Q205.30 81.93 205.30 81.49L205.30 81.49Q205.30 80.96 206.23 78.36Q207.15 75.77 208.34 72.12Q209.53 68.46 210.45 64.68Q211.38 60.90 211.38 57.99L211.38 57.99Q211.90 57.38 213.05 56.76Q214.19 56.14 215.42 56.14L215.42 56.14Q216.66 56.14 217.23 56.76Q217.80 57.38 217.80 58.43L217.80 58.43Q217.80 59.58 217.14 62.35Q216.48 65.12 215.51 68.46L215.51 68.46Q217.27 65.65 219.52 62.70Q221.76 59.75 224.22 57.29Q226.69 54.82 229.20 53.28Q231.70 51.74 234.08 51.74L234.08 51.74Q236.81 51.74 237.82 53.72Q238.83 55.70 238.83 58.43L238.83 58.43Q238.83 60.63 238.35 63.05Q237.86 65.47 237.25 67.54Q236.63 69.61 236.10 70.84L236.10 70.84Q237.95 67.50 240.20 64.37Q242.44 61.25 245.08 59.27Q247.72 57.29 250.71 57.29L250.71 57.29Q253.53 57.29 254.63 58.96Q255.73 60.63 255.73 62.92L255.73 62.92Q255.73 65.21 254.94 67.94Q254.14 70.66 253.31 73.22Q252.47 75.77 252.47 77.62L252.47 77.62Q252.47 78.76 253.04 79.68Q253.62 80.61 255.11 80.61L255.11 80.61Q257.58 80.61 259.73 78.36Q261.89 76.12 263.74 72.91Q265.58 69.70 266.90 66.70L266.90 66.70L267.96 67.94Q266.55 71.63 264.35 75.28Q262.15 78.94 259.20 81.31Q256.26 83.69 252.74 83.69Z',
      ),
    ];
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _vietnamTextTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showFill = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _vietnamTextTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: 270, // width for the SVG path bounding box
        height: 100, // height for the SVG path
        child: Transform.translate(
          offset: const Offset(-8, -10),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _progress,
                builder: (context, _) => CustomPaint(
                  size: const Size(270, 100),
                  painter: _PathDrawPainter(
                    _vietnamPaths,
                    Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3.0
                      ..color = Colors.white
                      ..strokeCap = StrokeCap.round
                      ..strokeJoin = StrokeJoin.round,
                    _progress.value,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: _showFill ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: CustomPaint(
                  size: const Size(270, 100),
                  painter: _PathFillPainter(
                    _vietnamPaths,
                    Paint()
                      ..style = PaintingStyle.fill
                      ..color = Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathDrawPainter extends CustomPainter {
  final List<Path> paths;
  final Paint strokePaint;
  final double progress;

  _PathDrawPainter(this.paths, this.strokePaint, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      final metrics = path.computeMetrics();
      for (final metric in metrics) {
        final extracted = metric.extractPath(
          0,
          metric.length * progress.clamp(0.0, 1.0),
        );
        canvas.drawPath(extracted, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathDrawPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _PathFillPainter extends CustomPainter {
  final List<Path> paths;
  final Paint fillPaint;

  _PathFillPainter(this.paths, this.fillPaint);

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      canvas.drawPath(path, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
