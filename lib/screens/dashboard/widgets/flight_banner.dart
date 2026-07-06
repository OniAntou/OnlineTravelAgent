import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../flights/flight_search_screen.dart';

class FlightBanner extends StatelessWidget {
  const FlightBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            FlightPageRoute(page: const FlightSearchScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF176FF2), Color(0xFF196EEE)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF176FF2).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flight_takeoff,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đặt vé máy bay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tìm chuyến bay giá rẻ nhất',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlightPageRoute extends PageRouteBuilder {
  final Widget page;

  FlightPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 3500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (animation.status == AnimationStatus.reverse) {
            return FadeTransition(opacity: animation, child: child);
          }

          final planeVal = Curves.easeOutCubic.transform(animation.value);

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              const planeSize = 800.0;
              const planeRadius = planeSize / 2;

              final travelAngle = math.atan2(-height, width);
              const visualRadius = planeRadius * 0.7;

              final startX = -visualRadius * math.cos(travelAngle);
              final startY = height - visualRadius * math.sin(travelAngle);

              const safeClearance = planeRadius * 1.5;
              final distanceToEnd =
                  safeClearance /
                  math.max(math.cos(travelAngle), -math.sin(travelAngle));

              final endX = width + distanceToEnd * math.cos(travelAngle);
              final endY = distanceToEnd * math.sin(travelAngle);

              final currentX = startX + (endX - startX) * planeVal;
              final currentY = startY + (endY - startY) * planeVal;

              const nativeAngle = -math.pi / 2;
              final rotation = travelAngle - nativeAngle;

              return Stack(
                children: [
                  ClipPath(
                    clipper: _WipeClipper(currentX, currentY, travelAngle),
                    child: child,
                  ),
                  Positioned(
                    left: currentX - planeRadius,
                    top: currentY - planeRadius,
                    child: Transform.rotate(
                      angle: rotation,
                      child: const _AirplaneWithTrails(planeSize: planeSize),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
}

class _AirplaneWithTrails extends StatelessWidget {
  final double planeSize;

  const _AirplaneWithTrails({required this.planeSize});

  Widget _buildSubtleTrail(
    double left,
    double top,
    double width,
    double length,
  ) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: length,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.withValues(alpha: 0.85),
              Colors.grey.withValues(alpha: 0.4),
              Colors.grey.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
          borderRadius: BorderRadius.circular(width / 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: planeSize,
      height: planeSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildSubtleTrail(315, 650, 150, 300), // Đuôi máy bay to hơn
          _buildSubtleTrail(88, 480, 24, 150), // Cánh trái to hơn
          _buildSubtleTrail(688, 480, 24, 150), // Cánh phải to hơn
          Icon(
            Icons.flight,
            size: planeSize,
            color: const Color(0xFF176FF2).withValues(alpha: 0.95),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(15, 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WipeClipper extends CustomClipper<Path> {
  final double currentX;
  final double currentY;
  final double travelAngle;

  static final Path _rectPath = Path()
    ..addRect(const Rect.fromLTRB(-4000, -4000, 0, 4000));

  _WipeClipper(this.currentX, this.currentY, this.travelAngle);

  @override
  Path getClip(Size size) {
    final matrix = Matrix4.translationValues(currentX, currentY, 0.0)
      ..rotateZ(travelAngle);

    return _rectPath.transform(matrix.storage);
  }

  @override
  bool shouldReclip(covariant _WipeClipper oldClipper) =>
      currentX != oldClipper.currentX ||
      currentY != oldClipper.currentY ||
      travelAngle != oldClipper.travelAngle;
}
