import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weathernow/presentation/weather_home_screen/weather_home_screen.dart';
import '../../../theme/app_theme.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dailyData;

  const DailyForecastWidget({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context) {
    // Global min/max for bar scaling
    final allLows = dailyData.map((d) => d['low'] as int).toList();
    final allHighs = dailyData.map((d) => d['high'] as int).toList();
    final globalMin = allLows.reduce((a, b) => a < b ? a : b).toDouble();
    final globalMax = allHighs.reduce((a, b) => a > b ? a : b).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: AppTheme.textMuted,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'PRONÓSTICO 7 DÍAS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: AppTheme.glassBorder,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              ...List.generate(dailyData.length, (index) {
                final item = dailyData[index];
                final isLast = index == dailyData.length - 1;
                return Column(
                  children: [
                    _DailyRow(
                      day: item['day'] as String,
                      condition: item['condition'] as WeatherCondition,
                      high: item['high'] as int,
                      low: item['low'] as int,
                      rainProbability: item['rainProbability'] as int,
                      globalMin: globalMin,
                      globalMax: globalMax,
                    ),
                    if (!isLast)
                      const Divider(
                        color: AppTheme.glassDeep,
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final String day;
  final WeatherCondition condition;
  final int high;
  final int low;
  final int rainProbability;
  final double globalMin;
  final double globalMax;

  const _DailyRow({
    required this.day,
    required this.condition,
    required this.high,
    required this.low,
    required this.rainProbability,
    required this.globalMin,
    required this.globalMax,
  });

  IconData get _icon {
    switch (condition) {
      case WeatherCondition.clear:
        return Icons.wb_sunny_rounded;
      case WeatherCondition.cloudy:
        return Icons.cloud_rounded;
      case WeatherCondition.rainy:
        return Icons.water_drop_rounded;
      case WeatherCondition.stormy:
        return Icons.thunderstorm_rounded;
      case WeatherCondition.snowy:
        return Icons.ac_unit_rounded;
      case WeatherCondition.foggy:
        return Icons.foggy;
      case WeatherCondition.sunrise:
        return Icons.wb_twilight_rounded;
    }
  }

  Color get _iconColor {
    switch (condition) {
      case WeatherCondition.clear:
        return AppTheme.sunriseGold;
      case WeatherCondition.cloudy:
        return AppTheme.textSecondary;
      case WeatherCondition.rainy:
        return AppTheme.clearAqua;
      case WeatherCondition.stormy:
        return AppTheme.errorRed;
      case WeatherCondition.snowy:
        return Colors.white;
      case WeatherCondition.foggy:
        return AppTheme.textMuted;
      case WeatherCondition.sunrise:
        return AppTheme.sunriseGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final range = globalMax - globalMin;
    final barStart = range > 0 ? (low - globalMin) / range : 0.0;
    final barEnd = range > 0 ? (high - globalMin) / range : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Day label
          SizedBox(
            width: 56,
            child: Text(
              day,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

          // Condition icon + rain prob
          SizedBox(
            width: 60,
            child: Row(
              children: [
                Icon(_icon, color: _iconColor, size: 20),
                if (rainProbability > 20) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$rainProbability%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: AppTheme.clearAqua,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Temperature range bar
          Expanded(
            child: Row(
              children: [
                Text(
                  '$low°',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(31),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Positioned(
                            left: constraints.maxWidth * barStart,
                            right: constraints.maxWidth * (1 - barEnd),
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.clearAqua,
                                    AppTheme.sunriseGold,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$high°',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
