import 'dart:math';
import 'package:flutter/material.dart';

class AzimuthNeedleHud extends StatelessWidget {
  final double deviceHeading; // 0..360
  final double targetBearing; // 0..360
  final double distanceMeters;
  final bool hasTarget;
  final String carrierName;
  final Color carrierColor;

  const AzimuthNeedleHud({
    super.key,
    required this.deviceHeading,
    required this.targetBearing,
    required this.distanceMeters,
    required this.hasTarget,
    required this.carrierName,
    required this.carrierColor,
  });

  @override
  Widget build(BuildContext context) {
    // Relative angle between device heading and tower bearing
    // (targetBearing - deviceHeading)
    double relativeAngleDeg = (targetBearing - deviceHeading) % 360.0;
    if (relativeAngleDeg > 180) relativeAngleDeg -= 360;

    // Is the user pointing within ±5 degrees of the tower? (Perfect for Yagi booster alignment!)
    final bool isAligned = hasTarget && relativeAngleDeg.abs() <= 5.0;
    final bool isClose = hasTarget && relativeAngleDeg.abs() <= 15.0;

    final Color accentColor = !hasTarget
        ? const Color(0xFF64748B)
        : isAligned
            ? const Color(0xFF10B981) // Emerald locked
            : isClose
                ? const Color(0xFFF59E0B) // Amber close
                : const Color(0xFF38BDF8); // Cyan standard

    final double needleRotationRad = (targetBearing - deviceHeading) * pi / 180.0;

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glowing Compass Bezel
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF111827),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: isAligned ? 0.35 : 0.12),
                      blurRadius: isAligned ? 36 : 24,
                      spreadRadius: isAligned ? 6 : 2,
                    ),
                  ],
                  border: Border.all(
                    color: isAligned ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                    width: isAligned ? 2.5 : 1.5,
                  ),
                ),
              ),

              // Rotating Compass Rose Ticks (rotates opposite of device heading)
              Transform.rotate(
                angle: -deviceHeading * pi / 180.0,
                child: SizedBox.expand(
                  child: CustomPaint(
                    painter: _CompassDialPainter(
                      dialColor: const Color(0xFF334155),
                      cardinalColor: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),

              // Concentric Range Rings (Radar Aesthetic)
              SizedBox.expand(
                child: CustomPaint(
                  painter: _RadarGridPainter(
                    gridColor: const Color(0xFF1E293B).withValues(alpha: 0.8),
                    isLocked: isAligned,
                  ),
                ),
              ),

              // Directional Target Needle
              if (hasTarget)
                Transform.rotate(
                  angle: needleRotationRad,
                  child: SizedBox.expand(
                    child: CustomPaint(
                      painter: _TargetNeedlePainter(
                        color: accentColor,
                        isAligned: isAligned,
                      ),
                    ),
                  ),
                ),

              // Center HUD Core Ring & Status Text
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0B0F19),
                  border: Border.all(
                    color: accentColor,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.25),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!hasTarget) ...[
                      const Icon(Icons.radar, color: Color(0xFF64748B), size: 28),
                      const SizedBox(height: 4),
                      const Text(
                        'NO TARGET',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ] else if (isAligned) ...[
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
                      const SizedBox(height: 2),
                      const Text(
                        'AIM LOCKED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      Text(
                        '±${relativeAngleDeg.abs().toStringAsFixed(1)}°',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF10B981),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ] else ...[
                      Text(
                        relativeAngleDeg > 0 ? 'TURN RIGHT' : 'TURN LEFT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${relativeAngleDeg.abs().toStringAsFixed(0)}°',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        carrierName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: carrierColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Fixed Top Pointer (User's Phone Heading Crosshair)
              Positioned(
                top: 6,
                child: Column(
                  children: [
                    Container(
                      width: 4,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isAligned ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: (isAligned ? const Color(0xFF10B981) : const Color(0xFF38BDF8)).withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${deviceHeading.toStringAsFixed(0).padLeft(3, '0')}°',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isAligned ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  final Color dialColor;
  final Color cardinalColor;

  _CompassDialPainter({
    required this.dialColor,
    required this.cardinalColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    final paintTickMajor = Paint()
      ..color = dialColor
      ..strokeWidth = 2.0;

    final paintTickMinor = Paint()
      ..color = dialColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    // Draw ticks every 15 degrees
    for (int deg = 0; deg < 360; deg += 15) {
      final rad = deg * pi / 180.0;
      final isCardinal = deg % 90 == 0;
      final isMajor = deg % 30 == 0;
      final tickLength = isCardinal ? 14.0 : (isMajor ? 9.0 : 5.0);

      final p1 = Offset(
        center.dx + radius * sin(rad),
        center.dy - radius * cos(rad),
      );
      final p2 = Offset(
        center.dx + (radius - tickLength) * sin(rad),
        center.dy - (radius - tickLength) * cos(rad),
      );

      canvas.drawLine(p1, p2, isMajor ? paintTickMajor : paintTickMinor);
    }

    // Cardinal Text: N, E, S, W
    const cardinals = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    for (final entry in cardinals.entries) {
      final rad = entry.key * pi / 180.0;
      final textSpan = TextSpan(
        text: entry.value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: entry.value == 'N' ? const Color(0xFFEF4444) : cardinalColor,
          letterSpacing: 0.5,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final textPos = Offset(
        center.dx + (radius - 26) * sin(rad) - textPainter.width / 2,
        center.dy - (radius - 26) * cos(rad) - textPainter.height / 2,
      );
      textPainter.paint(canvas, textPos);
    }
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) => false;
}

class _RadarGridPainter extends CustomPainter {
  final Color gridColor;
  final bool isLocked;

  _RadarGridPainter({required this.gridColor, required this.isLocked});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 38;

    final paintCircle = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, maxRadius * 0.45, paintCircle);
    canvas.drawCircle(center, maxRadius * 0.75, paintCircle);

    // Subtle crosshairs
    final paintLine = Paint()
      ..color = gridColor.withValues(alpha: 0.4)
      ..strokeWidth = 0.8;

    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), paintLine);
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), paintLine);
  }

  @override
  bool shouldRepaint(covariant _RadarGridPainter oldDelegate) => oldDelegate.isLocked != isLocked;
}

class _TargetNeedlePainter extends CustomPainter {
  final Color color;
  final bool isAligned;

  _TargetNeedlePainter({required this.color, required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Outer glow for needle
    final glowPaint = Paint()
      ..color = color.withValues(alpha: isAligned ? 0.6 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isAligned ? 6.0 : 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Arrowhead Path pointing UP (0 rad)
    final arrowPath = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx - 14, center.dy - radius + 32)
      ..lineTo(center.dx - 4, center.dy - radius + 28)
      ..lineTo(center.dx - 4, center.dy - 56)
      ..lineTo(center.dx + 4, center.dy - 56)
      ..lineTo(center.dx + 4, center.dy - radius + 28)
      ..lineTo(center.dx + 14, center.dy - radius + 32)
      ..close();

    canvas.drawPath(arrowPath, glowPaint);

    final solidPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, solidPaint);

    // Tail Feather (opposite end)
    final tailPath = Path()
      ..moveTo(center.dx - 5, center.dy + 56)
      ..lineTo(center.dx + 5, center.dy + 56)
      ..lineTo(center.dx + 8, center.dy + radius * 0.6)
      ..lineTo(center.dx - 8, center.dy + radius * 0.6)
      ..close();

    final tailPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawPath(tailPath, tailPaint);
  }

  @override
  bool shouldRepaint(covariant _TargetNeedlePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isAligned != isAligned;
}
