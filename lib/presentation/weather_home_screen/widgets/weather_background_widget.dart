import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../weather_home_screen.dart';

class WeatherBackgroundWidget extends StatelessWidget {
  final WeatherCondition condition;
  final bool isNight;
  final List<Color> gradient;
  final AnimationController controller;

  const WeatherBackgroundWidget({
    super.key,
    required this.condition,
    required this.isNight,
    required this.gradient,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated overlay particles/effects
              if (condition == WeatherCondition.rainy ||
                  condition == WeatherCondition.stormy)
                _RainOverlay(controller: controller),
              if (condition == WeatherCondition.cloudy ||
                  condition == WeatherCondition.rainy ||
                  condition == WeatherCondition.stormy)
                _CloudOverlay(controller: controller),
              if (condition == WeatherCondition.clear && !isNight)
                _SunRaysOverlay(controller: controller),
              if (isNight) _StarFieldOverlay(controller: controller),
              if (condition == WeatherCondition.snowy)
                _SnowOverlay(controller: controller),
              if (condition == WeatherCondition.stormy)
                _LightningOverlay(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

class _RainOverlay extends StatelessWidget {
  final AnimationController controller;

  const _RainOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RainPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RainPainter extends CustomPainter {
  final double progress;
  final math.Random _random = math.Random(42);

  _RainPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(31)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final x = (_random.nextDouble() * size.width);
      final startY = ((_random.nextDouble() + progress) % 1.0) * size.height;
      final length = 12.0 + _random.nextDouble() * 20;
      canvas.drawLine(Offset(x, startY), Offset(x - 3, startY + length), paint);
    }
  }

  @override
  bool shouldRepaint(_RainPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CloudOverlay extends StatelessWidget {
  final AnimationController controller;

  const _CloudOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CloudPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CloudPainter extends CustomPainter {
  final double progress;

  _CloudPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..style = PaintingStyle.fill;

    final offset = progress * 40;

    // Cloud 1
    _drawCloud(
      canvas,
      paint,
      size.width * 0.2 + offset,
      size.height * 0.15,
      80,
    );
    // Cloud 2
    _drawCloud(
      canvas,
      paint,
      size.width * 0.7 - offset * 0.5,
      size.height * 0.08,
      60,
    );
    // Cloud 3
    _drawCloud(
      canvas,
      paint,
      size.width * 0.5 + offset * 0.3,
      size.height * 0.25,
      100,
    );
  }

  void _drawCloud(Canvas canvas, Paint paint, double x, double y, double size) {
    canvas.drawCircle(Offset(x, y), size * 0.4, paint);
    canvas.drawCircle(
      Offset(x + size * 0.3, y + size * 0.05),
      size * 0.3,
      paint,
    );
    canvas.drawCircle(
      Offset(x - size * 0.25, y + size * 0.08),
      size * 0.28,
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(x - size * 0.4, y, size * 0.9, size * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CloudPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SunRaysOverlay extends StatelessWidget {
  final AnimationController controller;

  const _SunRaysOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SunRaysPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SunRaysPainter extends CustomPainter {
  final double progress;

  _SunRaysPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.75, size.height * 0.12);
    final paint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..strokeWidth = 2;

    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2 / 12) + (progress * 0.3);
      final rayLength = 60.0 + math.sin(progress * math.pi * 2 + i) * 10;
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * 28,
          center.dy + math.sin(angle) * 28,
        ),
        Offset(
          center.dx + math.cos(angle) * rayLength,
          center.dy + math.sin(angle) * rayLength,
        ),
        paint,
      );
    }

    // Sun glow
    final glowPaint = Paint()
      ..color = Colors.white.withAlpha(38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, 30 + progress * 5, glowPaint);
    canvas.drawCircle(center, 20, Paint()..color = Colors.white.withAlpha(77));
  }

  @override
  bool shouldRepaint(_SunRaysPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _StarFieldOverlay extends StatelessWidget {
  final AnimationController controller;

  const _StarFieldOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarFieldPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  final double progress;
  final math.Random _random = math.Random(99);

  _StarFieldPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 80; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height * 0.6;
      final twinkle = math.sin(progress * math.pi * 2 + i * 0.5);
      final opacity = 0.3 + twinkle * 0.3;
      final radius = 0.8 + _random.nextDouble() * 1.5;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = Colors.white.withOpacity(opacity.clamp(0.1, 0.9)),
      );
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SnowOverlay extends StatelessWidget {
  final AnimationController controller;

  const _SnowOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SnowPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SnowPainter extends CustomPainter {
  final double progress;
  final math.Random _random = math.Random(77);

  _SnowPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(102);

    for (int i = 0; i < 40; i++) {
      final x =
          _random.nextDouble() * size.width +
          math.sin(progress * math.pi * 2 + i) * 15;
      final y = ((_random.nextDouble() + progress) % 1.0) * size.height;
      final radius = 2.0 + _random.nextDouble() * 3;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SnowPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─── Lightning Overlay ────────────────────────────────────────────────────────

class _LightningOverlay extends StatelessWidget {
  final AnimationController controller;

  const _LightningOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _LightningPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _LightningPainter extends CustomPainter {
  final double progress;

  _LightningPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Flash effect — brief bright overlay at certain progress points
    final flashPhase = (progress * 3) % 1.0;
    if (flashPhase > 0.92) {
      final flashOpacity = (1.0 - flashPhase) * 10;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..color = Colors.white.withOpacity(flashOpacity.clamp(0.0, 0.08)),
      );
    }

    // Draw zigzag lightning bolt
    final boltPhase = (progress * 2) % 1.0;
    if (boltPhase < 0.15) {
      final opacity = (0.15 - boltPhase) / 0.15;
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.7)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final startX = size.width * 0.65;
      final path = Path()
        ..moveTo(startX, 0)
        ..lineTo(startX - 15, size.height * 0.25)
        ..lineTo(startX + 10, size.height * 0.25)
        ..lineTo(startX - 20, size.height * 0.55)
        ..lineTo(startX + 5, size.height * 0.55)
        ..lineTo(startX - 30, size.height * 0.85);

      canvas.drawPath(path, paint);

      // Glow
      final glowPaint = Paint()
        ..color = Colors.yellowAccent.withOpacity(opacity * 0.3)
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_LightningPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
