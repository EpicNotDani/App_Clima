import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final IconData? icon;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withAlpha(102)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor ?? color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor ?? color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
