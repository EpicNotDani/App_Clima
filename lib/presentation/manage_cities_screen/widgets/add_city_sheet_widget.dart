import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../manage_cities_screen.dart';
import '../../../services/weather_service.dart';

class AddCitySheetWidget extends StatefulWidget {
  final Function(CityData) onCityAdded;

  const AddCitySheetWidget({super.key, required this.onCityAdded});

  @override
  State<AddCitySheetWidget> createState() => _AddCitySheetWidgetState();
}

class _AddCitySheetWidgetState extends State<AddCitySheetWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  bool _isSearching = false;
  bool _isLoadingWeather = false;
  List<GeocodingResult> _searchResults = [];
  String? _errorMessage;

  final WeatherService _weatherService = WeatherService();

  // Popular cities with their geocoding data for quick access
  static const List<Map<String, dynamic>> _popularCities = [
    {
      'name': 'Buenos Aires',
      'lat': -34.6037,
      'lon': -58.3816,
      'country': 'AR',
      'countryFull': 'Argentina',
      'tz': 'America/Argentina/Buenos_Aires',
    },
    {
      'name': 'São Paulo',
      'lat': -23.5505,
      'lon': -46.6333,
      'country': 'BR',
      'countryFull': 'Brasil',
      'tz': 'America/Sao_Paulo',
    },
    {
      'name': 'Lima',
      'lat': -12.0464,
      'lon': -77.0428,
      'country': 'PE',
      'countryFull': 'Perú',
      'tz': 'America/Lima',
    },
    {
      'name': 'Santiago',
      'lat': -33.4489,
      'lon': -70.6693,
      'country': 'CL',
      'countryFull': 'Chile',
      'tz': 'America/Santiago',
    },
    {
      'name': 'Nueva York',
      'lat': 40.7128,
      'lon': -74.0060,
      'country': 'US',
      'countryFull': 'Estados Unidos',
      'tz': 'America/New_York',
    },
    {
      'name': 'Londres',
      'lat': 51.5074,
      'lon': -0.1278,
      'country': 'GB',
      'countryFull': 'Reino Unido',
      'tz': 'Europe/London',
    },
    {
      'name': 'Tokio',
      'lat': 35.6762,
      'lon': 139.6503,
      'country': 'JP',
      'countryFull': 'Japón',
      'tz': 'Asia/Tokyo',
    },
    {
      'name': 'París',
      'lat': 48.8566,
      'lon': 2.3522,
      'country': 'FR',
      'countryFull': 'Francia',
      'tz': 'Europe/Paris',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    if (query.trim().length < 2) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    _weatherService
        .searchCities(query)
        .then((results) {
          if (!mounted) return;
          setState(() {
            _searchResults = results;
            _isSearching = false;
            _errorMessage = results.isEmpty ? null : null;
          });
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() {
            _isSearching = false;
            _errorMessage = 'Error al buscar. Verifica tu conexión.';
          });
        });
  }

  Future<void> _selectGeocodingResult(GeocodingResult result) async {
    setState(() => _isLoadingWeather = true);

    final cityData = await _weatherService.fetchWeatherForLocation(
      latitude: result.latitude,
      longitude: result.longitude,
      cityName: result.name,
      countryCode: result.countryCode,
      countryFull: result.country,
      timezone: result.timezone,
      isCurrentLocation: false,
    );

    if (!mounted) return;
    setState(() => _isLoadingWeather = false);

    if (cityData != null) {
      widget.onCityAdded(cityData);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo obtener el clima para ${result.name}',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: AppTheme.stormGrey,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _selectPopularCity(Map<String, dynamic> cityInfo) async {
    setState(() => _isLoadingWeather = true);

    final cityData = await _weatherService.fetchWeatherForLocation(
      latitude: cityInfo['lat'] as double,
      longitude: cityInfo['lon'] as double,
      cityName: cityInfo['name'] as String,
      countryCode: cityInfo['country'] as String,
      countryFull: cityInfo['countryFull'] as String,
      timezone: cityInfo['tz'] as String,
      isCurrentLocation: false,
    );

    if (!mounted) return;
    setState(() => _isLoadingWeather = false);

    if (cityData != null) {
      widget.onCityAdded(cityData);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo obtener el clima para ${cityInfo['name']}',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: AppTheme.stormGrey,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: EdgeInsets.only(bottom: bottomPadding + 16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xCC0D2137), Color(0xCC0A1628)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.glassBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              'Agregar Ciudad',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppTheme.textMuted,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.glassSurface,
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _SheetSearchField(
                          controller: _searchController,
                          onChanged: _performSearch,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Results
                      Flexible(child: _buildResults()),
                    ],
                  ),

                  // Full-screen loading overlay when fetching weather
                  if (_isLoadingWeather)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(153),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: AppTheme.clearAqua,
                              strokeWidth: 2.5,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Obteniendo datos del clima...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.clearAqua,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppTheme.textMuted,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CIUDADES POPULARES',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularCities
                  .map(
                    (city) => _PopularCityChip(
                      label: city['name'] as String,
                      onTap: () => _selectPopularCity(city),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: AppTheme.textMuted,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Sin resultados para "${_searchController.text}"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _GeocodingResultTile(
          result: result,
          onTap: () => _selectGeocodingResult(result),
        );
      },
    );
  }
}

class _SheetSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SheetSearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar cualquier ciudad del mundo...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppTheme.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textMuted,
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _PopularCityChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PopularCityChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.glassSurface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _GeocodingResultTile extends StatelessWidget {
  final GeocodingResult result;
  final VoidCallback onTap;

  const _GeocodingResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withAlpha(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.glassSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.clearAqua.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.clearAqua,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.admin1 != null &&
                                result.admin1!.isNotEmpty &&
                                result.admin1 != result.name
                            ? '${result.admin1}, ${result.country}'
                            : result.country,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.skyBlue.withAlpha(64),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.skyBlue.withAlpha(102)),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppTheme.clearAqua,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
