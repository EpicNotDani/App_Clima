import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../weather_home_screen.dart';

class LifestyleTipsWidget extends StatelessWidget {
  final WeatherCondition condition;
  final int uvIndex;
  final int humidity;

  const LifestyleTipsWidget({
    super.key,
    required this.condition,
    required this.uvIndex,
    required this.humidity,
  });

  List<_LifestyleTip> get _tips {
    final isRainy =
        condition == WeatherCondition.rainy ||
        condition == WeatherCondition.stormy;
    final highUV = uvIndex >= 6;
    final highHumidity = humidity >= 75;

    return [
      _LifestyleTip(
        icon: Icons.local_florist_rounded,
        label: 'Polen',
        status: isRainy ? 'Bajo' : (highHumidity ? 'Moderado' : 'Alto'),
        statusColor: isRainy
            ? AppTheme.success
            : (highHumidity ? AppTheme.warning : AppTheme.errorRed),
        iconColor: const Color(0xFFA5D6A7),
      ),
      _LifestyleTip(
        icon: Icons.wb_sunny_rounded,
        label: 'Índice UV',
        status: uvIndex <= 2
            ? 'Bajo'
            : uvIndex <= 5
            ? 'Moderado'
            : 'Alto',
        statusColor: uvIndex <= 2
            ? AppTheme.success
            : uvIndex <= 5
            ? AppTheme.warning
            : AppTheme.errorRed,
        iconColor: AppTheme.sunriseGold,
      ),
      _LifestyleTip(
        icon: Icons.local_car_wash_rounded,
        label: 'Lavar coche',
        status: isRainy ? 'No recomendado' : 'Buenas cond.',
        statusColor: isRainy ? AppTheme.errorRed : AppTheme.success,
        iconColor: AppTheme.clearAqua,
      ),
      _LifestyleTip(
        icon: Icons.directions_run_rounded,
        label: 'Ejercicio',
        status: isRainy
            ? 'Interior'
            : highUV
            ? 'Evitar mediodía'
            : 'Ideal',
        statusColor: isRainy
            ? AppTheme.warning
            : highUV
            ? AppTheme.warning
            : AppTheme.success,
        iconColor: const Color(0xFF80CBC4),
      ),
      _LifestyleTip(
        icon: Icons.directions_car_rounded,
        label: 'Conducción',
        status: condition == WeatherCondition.stormy
            ? 'Precaución'
            : isRainy
            ? 'Cuidado'
            : 'Normal',
        statusColor: condition == WeatherCondition.stormy
            ? AppTheme.errorRed
            : isRainy
            ? AppTheme.warning
            : AppTheme.success,
        iconColor: AppTheme.textSecondary,
      ),
      _LifestyleTip(
        icon: Icons.flight_rounded,
        label: 'Viajes',
        status: condition == WeatherCondition.stormy
            ? 'Posibles retrasos'
            : isRainy
            ? 'Verificar vuelos'
            : 'Favorable',
        statusColor: condition == WeatherCondition.stormy
            ? AppTheme.errorRed
            : isRainy
            ? AppTheme.warning
            : AppTheme.success,
        iconColor: const Color(0xFFCE93D8),
      ),
      _LifestyleTip(
        icon: Icons.pest_control_rounded,
        label: 'Mosquitos',
        status: highHumidity && isRainy
            ? 'Alto riesgo'
            : highHumidity
            ? 'Moderado'
            : 'Bajo',
        statusColor: highHumidity && isRainy
            ? AppTheme.errorRed
            : highHumidity
            ? AppTheme.warning
            : AppTheme.success,
        iconColor: const Color(0xFFFFCC80),
      ),
      _LifestyleTip(
        icon: Icons.umbrella_rounded,
        label: 'Paraguas',
        status: isRainy ? 'Necesario' : 'No necesario',
        statusColor: isRainy ? AppTheme.clearAqua : AppTheme.success,
        iconColor: AppTheme.clearAqua,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tips = _tips;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4),
          child: Row(
            children: [
              const Icon(
                Icons.tips_and_updates_rounded,
                color: AppTheme.textMuted,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'ESTILO DE VIDA',
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
            childAspectRatio: 2.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: tips.length,
          itemBuilder: (context, index) {
            return _LifestyleTipCard(tip: tips[index]);
          },
        ),
      ],
    );
  }
}

class _LifestyleTip {
  final IconData icon;
  final String label;
  final String status;
  final Color statusColor;
  final Color iconColor;

  const _LifestyleTip({
    required this.icon,
    required this.label,
    required this.status,
    required this.statusColor,
    required this.iconColor,
  });
}

class _LifestyleTipCard extends StatelessWidget {
  final _LifestyleTip tip;

  const _LifestyleTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tip.iconColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tip.icon, color: tip.iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tip.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tip.status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: tip.statusColor,
                      ),
                      overflow: TextOverflow.ellipsis,
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
