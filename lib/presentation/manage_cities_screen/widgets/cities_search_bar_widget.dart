import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class CitiesSearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CitiesSearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<CitiesSearchBarWidget> createState() => _CitiesSearchBarWidgetState();
}

class _CitiesSearchBarWidgetState extends State<CitiesSearchBarWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? AppTheme.clearAqua.withAlpha(153)
              : AppTheme.glassBorder,
          width: _isFocused ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar ciudad...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        widget.controller.clear();
                        widget.onChanged('');
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.textMuted,
                        size: 18,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.glassSurface,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
