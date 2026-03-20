import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../weather_home_screen.dart';

class RainAlertWidget extends StatelessWidget {
  final WeatherCondition condition;
  final int probability;
  final int duration;

  const RainAlertWidget({
    super.key,
    required this.condition,
    required this.probability,
    required this.duration,
  });

  bool get _showAlert =>
      condition == WeatherCondition.rainy ||
      condition == WeatherCondition.stormy ||
      probability > 50;

  @override
  Widget build(BuildContext context) {
    if (!_showAlert) {
      return _buildClearAlert();
    }
    return _buildRainAlert();
  }

  Widget _buildRainAlert() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withAlpha(115),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Row(
            children: [
              // Rain icon animated container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.clearAqua.withAlpha(51),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.clearAqua.withAlpha(102)),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: AppTheme.clearAqua,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Alerta de lluvia',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.clearAqua.withAlpha(51),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '$probability%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.clearAqua,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Previsión de lluvia durante $duration horas. Probabilidad de lluvias continuas.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Probability bar
                    Stack(
                      children: [
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(38),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: probability / 100,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.clearAqua, Color(0xFF1565C0)],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildClearAlert() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.success.withAlpha(38),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.success.withAlpha(77)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.success.withAlpha(51),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: AppTheme.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Sin precipitaciones en las próximas horas. Disfruta el buen tiempo.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
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
