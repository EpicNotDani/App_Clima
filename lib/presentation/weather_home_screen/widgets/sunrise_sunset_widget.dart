import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class SunriseSunsetWidget extends StatelessWidget {
  final String sunriseTime;
  final String sunsetTime;

  const SunriseSunsetWidget({
    super.key,
    required this.sunriseTime,
    required this.sunsetTime,
  });

  double _timeToMinutes(String time) {
    final parts = time.split(':');
    return double.parse(parts[0]) * 60 + double.parse(parts[1]);
  }

  double get _sunPosition {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60.0 + now.minute;
    final sunriseMinutes = _timeToMinutes(sunriseTime);
    final sunsetMinutes = _timeToMinutes(sunsetTime);

    if (currentMinutes <= sunriseMinutes) return 0.0;
    if (currentMinutes >= sunsetMinutes) return 1.0;

    return (currentMinutes - sunriseMinutes) / (sunsetMinutes - sunriseMinutes);
  }

  String get _daylightDuration {
    final sunrise = _timeToMinutes(sunriseTime);
    final sunset = _timeToMinutes(sunsetTime);
    final diff = (sunset - sunrise).round();
    final hours = diff ~/ 60;
    final minutes = diff % 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.wb_twilight_rounded,
                    color: AppTheme.textMuted,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AMANECER / PUESTA DE SOL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sun arc painter
              SizedBox(
                height: 100,
                child: CustomPaint(
                  painter: _SunArcPainter(sunPosition: _sunPosition),
                  size: const Size(double.infinity, 100),
                ),
              ),

              const SizedBox(height: 12),

              // Sunrise / Sunset labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SunTimeLabel(
                    icon: Icons.wb_sunny_rounded,
                    label: 'Amanecer',
                    time: sunriseTime,
                    color: AppTheme.sunriseGold,
                  ),
                  Column(
                    children: [
                      Text(
                        _daylightDuration,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Horas de luz',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  _SunTimeLabel(
                    icon: Icons.nights_stay_rounded,
                    label: 'Puesta de sol',
                    time: sunsetTime,
                    color: const Color(0xFF7E57C2),
                    alignRight: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double sunPosition;

  const _SunArcPainter({required this.sunPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height + 10;
    final radius = size.width * 0.52;

    // Ground line
    final groundPaint = Paint()
      ..color = Colors.white.withAlpha(38)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height - 2),
      Offset(size.width, size.height - 2),
      groundPaint,
    );

    // Arc path (semi-circle above ground)
    final arcRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: radius * 2,
      height: radius * 2,
    );

    // Background arc (dashed appearance via segments)
    final bgArcPaint = Paint()
      ..color = Colors.white.withAlpha(31)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, math.pi, math.pi, false, bgArcPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppTheme.sunriseGold.withAlpha(204), AppTheme.sunriseGold],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      arcRect,
      math.pi,
      math.pi * sunPosition,
      false,
      progressPaint,
    );

    // Sun position on arc
    final sunAngle = math.pi + math.pi * sunPosition;
    final sunX = centerX + radius * math.cos(sunAngle);
    final sunY = centerY + radius * math.sin(sunAngle);

    // Sun glow
    final glowPaint = Paint()
      ..color = AppTheme.sunriseGold.withAlpha(64)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(sunX, sunY), 14, glowPaint);

    // Sun body
    final sunPaint = Paint()..color = AppTheme.sunriseGold;
    canvas.drawCircle(Offset(sunX, sunY), 8, sunPaint);

    // Sun inner highlight
    final innerPaint = Paint()..color = Colors.white.withAlpha(153);
    canvas.drawCircle(Offset(sunX - 2, sunY - 2), 3, innerPaint);
  }

  @override
  bool shouldRepaint(_SunArcPainter oldDelegate) =>
      oldDelegate.sunPosition != sunPosition;
}

class _SunTimeLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;
  final bool alignRight;

  const _SunTimeLabel({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignRight) ...[
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
            if (alignRight) ...[
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 14),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
