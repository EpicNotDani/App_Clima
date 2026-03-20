import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class WeatherDetailGridWidget extends StatelessWidget {
  final int feelsLike;
  final int humidity;
  final int windSpeed;
  final String windDirection;
  final int uvIndex;
  final int pressure;
  final double visibility;
  final int dewPoint;

  const WeatherDetailGridWidget({
    super.key,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.uvIndex,
    required this.pressure,
    required this.visibility,
    required this.dewPoint,
  });

  String get _uvLabel {
    if (uvIndex <= 2) return 'Bajo';
    if (uvIndex <= 5) return 'Moderado';
    if (uvIndex <= 7) return 'Alto';
    if (uvIndex <= 10) return 'Muy Alto';
    return 'Extremo';
  }

  Color get _uvColor {
    if (uvIndex <= 2) return AppTheme.success;
    if (uvIndex <= 5) return AppTheme.sunriseGold;
    if (uvIndex <= 7) return AppTheme.warning;
    return AppTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _DetailItem(
        icon: Icons.wb_sunny_outlined,
        iconColor: _uvColor,
        label: 'Índice UV',
        value: '$uvIndex',
        unit: _uvLabel,
        subLabel: 'Protección recomendada',
      ),
      _DetailItem(
        icon: Icons.thermostat_rounded,
        iconColor: AppTheme.sunriseGold,
        label: 'Sensación',
        value: '$feelsLike°',
        unit: 'C',
        subLabel: 'Temperatura aparente',
      ),
      _DetailItem(
        icon: Icons.water_drop_outlined,
        iconColor: AppTheme.clearAqua,
        label: 'Humedad',
        value: '$humidity',
        unit: '%',
        subLabel: 'Punto de rocío $dewPoint°C',
      ),
      _DetailItem(
        icon: Icons.air_rounded,
        iconColor: const Color(0xFF80CBC4),
        label: 'Viento',
        value: '$windSpeed',
        unit: 'km/h $windDirection',
        subLabel: 'Velocidad del viento',
      ),
      _DetailItem(
        icon: Icons.speed_rounded,
        iconColor: AppTheme.textSecondary,
        label: 'Presión',
        value: '$pressure',
        unit: 'hPa',
        subLabel: 'Presión atmosférica',
      ),
      _DetailItem(
        icon: Icons.visibility_outlined,
        iconColor: const Color(0xFF80DEEA),
        label: 'Visibilidad',
        value: '$visibility',
        unit: 'km',
        subLabel: 'Alcance visual',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4),
          child: Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: AppTheme.textMuted,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'CONDICIONES ACTUALES',
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _DetailCard(item: items[index]);
          },
        ),
      ],
    );
  }
}

class _DetailItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final String subLabel;

  const _DetailItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.subLabel,
  });
}

class _DetailCard extends StatelessWidget {
  final _DetailItem item;

  const _DetailCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(item.icon, color: item.iconColor, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.label.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      item.unit,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                item.subLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
