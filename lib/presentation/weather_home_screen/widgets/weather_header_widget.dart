import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class WeatherHeaderWidget extends StatelessWidget {
  final String city;
  final String country;
  final VoidCallback onMenuTap;
  final VoidCallback onSettingsTap;

  const WeatherHeaderWidget({
    super.key,
    required this.city,
    required this.country,
    required this.onMenuTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // Location info
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.glassSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.glassBorder),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.clearAqua,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Mi Ubicación · $country',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              _HeaderIconButton(
                icon: Icons.location_city_rounded,
                onTap: onMenuTap,
                tooltip: 'Administrar ciudades',
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                icon: Icons.settings_rounded,
                onTap: onSettingsTap,
                tooltip: 'Ajustes',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withAlpha(26),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.glassSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Icon(icon, color: AppTheme.textPrimary, size: 20),
          ),
        ),
      ),
    );
  }
}
