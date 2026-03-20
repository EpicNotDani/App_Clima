import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class WeatherHeroWidget extends StatelessWidget {
  final int temperature;
  final String condition;
  final int high;
  final int low;

  const WeatherHeroWidget({
    super.key,
    required this.temperature,
    required this.condition,
    required this.high,
    required this.low,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main temperature — hero size
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$temperature',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 96,
                  fontWeight: FontWeight.w200,
                  color: AppTheme.textPrimary,
                  height: 1.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  '°C',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Condition text
          Text(
            condition,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 10),

          // High / Low
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.glassSurface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TempBadge(label: 'Máx', value: high, color: AppTheme.warning),
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppTheme.glassBorder,
                ),
                _TempBadge(label: 'Mín', value: low, color: AppTheme.clearAqua),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Last updated
          Text(
            'Actualizado: ${_formatTime(DateTime.now())}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _TempBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _TempBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$value°',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
