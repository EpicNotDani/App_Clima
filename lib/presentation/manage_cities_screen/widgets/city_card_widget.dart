import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../weather_home_screen/weather_home_screen.dart';
import '../manage_cities_screen.dart';

class CityCardWidget extends StatelessWidget {
  final CityData city;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CityCardWidget({
    super.key,
    required this.city,
    required this.onTap,
    required this.onDelete,
  });

  List<Color> get _cardGradient {
    switch (city.weatherCondition) {
      case WeatherCondition.clear:
        return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
      case WeatherCondition.cloudy:
        return [const Color(0xFF37474F), const Color(0xFF607D8B)];
      case WeatherCondition.rainy:
        return [const Color(0xFF1A237E), const Color(0xFF3949AB)];
      case WeatherCondition.stormy:
        return [const Color(0xFF212121), const Color(0xFF455A64)];
      case WeatherCondition.snowy:
        return [const Color(0xFF546E7A), const Color(0xFF90A4AE)];
      case WeatherCondition.foggy:
        return [const Color(0xFF546E7A), const Color(0xFF78909C)];
      case WeatherCondition.sunrise:
        return [const Color(0xFF4A148C), const Color(0xFFE65100)];
    }
  }

  IconData get _weatherIcon {
    switch (city.weatherCondition) {
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

  Color get _weatherIconColor {
    switch (city.weatherCondition) {
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withAlpha(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _cardGradient[0].withAlpha(140),
                    _cardGradient[1].withAlpha(89),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: city.isCurrentLocation
                      ? AppTheme.clearAqua.withAlpha(128)
                      : AppTheme.glassBorder,
                  width: city.isCurrentLocation ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left — city info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // City name + location pin
                        Row(
                          children: [
                            if (city.isCurrentLocation) ...[
                              const Icon(
                                Icons.my_location_rounded,
                                color: AppTheme.clearAqua,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                city.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              city.countryFull,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppTheme.textMuted,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              city.localTime,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Condition + humidity row
                        Row(
                          children: [
                            Icon(_weatherIcon,
                                color: _weatherIconColor, size: 14),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                city.condition,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.water_drop_rounded,
                                color: AppTheme.clearAqua.withAlpha(179),
                                size: 12),
                            const SizedBox(width: 3),
                            Text(
                              '${city.humidity}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right — temperature
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${city.temperature}°',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 42,
                          fontWeight: FontWeight.w200,
                          color: AppTheme.textPrimary,
                          height: 1.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${city.high}° / ${city.low}°',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (city.isCurrentLocation) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.clearAqua.withAlpha(38),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: AppTheme.clearAqua.withAlpha(102)),
                          ),
                          child: Text(
                            'Mi ubicación',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.clearAqua,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}