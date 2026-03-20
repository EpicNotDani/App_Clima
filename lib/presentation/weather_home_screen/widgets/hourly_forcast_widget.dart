import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../weather_home_screen.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyData;

  const HourlyForecastWidget({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: AppTheme.textMuted,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'PRONÓSTICO POR HORA',
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
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: hourlyData.length,
                  itemBuilder: (context, index) {
                    final item = hourlyData[index];
                    final isNow = item['isNow'] as bool? ?? false;
                    return _HourlyItem(
                      time: item['time'] as String,
                      condition: item['condition'] as WeatherCondition,
                      temperature: item['temperature'] as int,
                      rainProbability: item['rainProbability'] as int,
                      isNow: isNow,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _HourlyItem extends StatelessWidget {
  final String time;
  final WeatherCondition condition;
  final int temperature;
  final int rainProbability;
  final bool isNow;

  const _HourlyItem({
    required this.time,
    required this.condition,
    required this.temperature,
    required this.rainProbability,
    required this.isNow,
  });

  IconData get _conditionIcon {
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

  Color get _conditionColor {
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 68,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: isNow
            ? AppTheme.skyBlue.withAlpha(89)
            : Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNow ? AppTheme.clearAqua.withAlpha(153) : Colors.transparent,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            time,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w400,
              color: isNow ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          Icon(_conditionIcon, color: _conditionColor, size: 22),
          Text(
            '$temperature°',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (rainProbability > 20)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 9,
                  color: AppTheme.clearAqua,
                ),
                const SizedBox(width: 2),
                Text(
                  '$rainProbability%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    color: AppTheme.clearAqua,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }
}
