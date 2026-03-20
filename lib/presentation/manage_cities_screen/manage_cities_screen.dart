import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/cities_store.dart';
import '../../theme/app_theme.dart';
import '../weather_home_screen/weather_home_screen.dart';
import './widgets/add_city_sheet_widget.dart';
import './widgets/cities_search_bar_widget.dart';
import './widgets/city_card_widget.dart';

class ManageCitiesScreen extends StatefulWidget {
  const ManageCitiesScreen({super.key});

  @override
  State<ManageCitiesScreen> createState() => _ManageCitiesScreenState();
}

class _ManageCitiesScreenState extends State<ManageCitiesScreen>
    with TickerProviderStateMixin {
  late AnimationController _listController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final CitiesStore _store = CitiesStore();

  List<CityData> get _cities => _store.cities.toList();

  List<CityData> get _filteredCities {
    if (_searchQuery.isEmpty) return _cities;
    final q = _searchQuery.toLowerCase();
    return _cities
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.country.toLowerCase().contains(q) ||
              c.countryFull.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _store.addListener(_onStoreChanged);
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _listController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _removeCity(String cityId) {
    final city = _cities.firstWhere((c) => c.id == cityId);
    if (city.isCurrentLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No puedes eliminar tu ubicación actual',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: AppTheme.stormGrey,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    _store.removeCity(cityId);
  }

  /// Tap on a city card → set it as current in the store and go back to home
  void _setCurrentCity(String cityId) {
    _store.setCurrentCityById(cityId);
    Navigator.pop(context);
  }

  void _showAddCitySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCitySheetWidget(
        onCityAdded: (cityData) {
          _store.addCity(cityData);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.deepNight,
      body: Stack(
        children: [
          // Dark atmospheric background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A1628),
                  Color(0xFF0D2137),
                  Color(0xFF111827),
                ],
              ),
            ),
          ),

          // Subtle star field
          CustomPaint(painter: _StaticStarsPainter(), size: Size.infinite),

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: CitiesSearchBarWidget(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),

                // Cities count
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredCities.length} ciudad${_filteredCities.length != 1 ? 'es' : ''}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Desliza para eliminar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Cities list
                Expanded(
                  child: _filteredCities.isEmpty
                      ? _buildEmptyState()
                      : isTablet
                      ? _buildTabletGrid()
                      : _buildPhoneList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCitySheet,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text(
          'Agregar ciudad',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        backgroundColor: AppTheme.skyBlue,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
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
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textPrimary,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Administrar Ciudades',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Toca para seleccionar ciudad activa',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      itemCount: _filteredCities.length,
      itemBuilder: (context, index) {
        final city = _filteredCities[index];
        final animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _listController,
            curve: Interval(
              (index * 0.08).clamp(0.0, 0.8),
              ((index * 0.08) + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(city.id),
                direction: city.isCurrentLocation
                    ? DismissDirection.none
                    : DismissDirection.endToStart,
                onDismissed: (_) => _removeCity(city.id),
                background: _buildSwipeBackground(),
                child: CityCardWidget(
                  city: city,
                  onTap: () => _setCurrentCity(city.id),
                  onDelete: () => _removeCity(city.id),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredCities.length,
      itemBuilder: (context, index) {
        final city = _filteredCities[index];
        return Dismissible(
          key: ValueKey(city.id),
          direction: city.isCurrentLocation
              ? DismissDirection.none
              : DismissDirection.endToStart,
          onDismissed: (_) => _removeCity(city.id),
          background: _buildSwipeBackground(),
          child: CityCardWidget(
            city: city,
            onTap: () => _setCurrentCity(city.id),
            onDelete: () => _removeCity(city.id),
          ),
        );
      },
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.errorRed.withAlpha(102)),
      ),
      child: const Icon(
        Icons.delete_rounded,
        color: AppTheme.errorRed,
        size: 24,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.glassSurface,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: const Icon(
              Icons.location_city_rounded,
              size: 40,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty
                ? 'Sin resultados para "$_searchQuery"'
                : 'No hay ciudades guardadas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Intenta con otro nombre de ciudad o país'
                : 'Agrega ciudades para seguir el clima en varios lugares',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.textMuted,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _showAddCitySheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar ciudad'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.skyBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StaticStarsPainter extends CustomPainter {
  final _random = math.Random(42);

  _StaticStarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(64);
    for (int i = 0; i < 60; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height * 0.5;
      canvas.drawCircle(Offset(x, y), 0.8 + _random.nextDouble() * 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(_StaticStarsPainter oldDelegate) => false;
}

// CityData model — extended with full weather fields
class CityData {
  final String id;
  final String name;
  final String country;
  final String countryFull;
  final int temperature;
  final String condition;
  final WeatherCondition weatherCondition;
  final int high;
  final int low;
  final int humidity;
  bool isCurrentLocation;
  final String timeZone;
  final String localTime;
  final int feelsLike;
  final int windSpeed;
  final String windDirection;
  final int pressure;
  final double visibility;
  final int cloudCover;
  final double? latitude;
  final double? longitude;

  CityData({
    required this.id,
    required this.name,
    required this.country,
    required this.countryFull,
    required this.temperature,
    required this.condition,
    required this.weatherCondition,
    required this.high,
    required this.low,
    required this.humidity,
    required this.isCurrentLocation,
    required this.timeZone,
    required this.localTime,
    this.feelsLike = 0,
    this.windSpeed = 0,
    this.windDirection = 'N',
    this.pressure = 1013,
    this.visibility = 10.0,
    this.cloudCover = 0,
    this.latitude,
    this.longitude,
  });

  factory CityData.fromMap(Map<String, dynamic> map) {
    return CityData(
      id: map['id'] as String,
      name: map['name'] as String,
      country: map['country'] as String,
      countryFull: map['countryFull'] as String,
      temperature: map['temperature'] as int,
      condition: map['condition'] as String,
      weatherCondition: _conditionFromString(map['weatherCondition'] as String),
      high: map['high'] as int,
      low: map['low'] as int,
      humidity: map['humidity'] as int,
      isCurrentLocation: map['isCurrentLocation'] as bool,
      timeZone: map['timeZone'] as String,
      localTime: map['localTime'] as String,
      feelsLike: (map['feelsLike'] as num?)?.toInt() ?? 0,
      windSpeed: (map['windSpeed'] as num?)?.toInt() ?? 0,
      windDirection: map['windDirection'] as String? ?? 'N',
      pressure: (map['pressure'] as num?)?.toInt() ?? 1013,
      visibility: (map['visibility'] as num?)?.toDouble() ?? 10.0,
      cloudCover: (map['cloudCover'] as num?)?.toInt() ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'country': country,
    'countryFull': countryFull,
    'temperature': temperature,
    'condition': condition,
    'weatherCondition': weatherCondition.name,
    'high': high,
    'low': low,
    'humidity': humidity,
    'isCurrentLocation': isCurrentLocation,
    'timeZone': timeZone,
    'localTime': localTime,
    'feelsLike': feelsLike,
    'windSpeed': windSpeed,
    'windDirection': windDirection,
    'pressure': pressure,
    'visibility': visibility,
    'cloudCover': cloudCover,
    'latitude': latitude,
    'longitude': longitude,
  };

  static WeatherCondition _conditionFromString(String v) {
    switch (v) {
      case 'clear':
        return WeatherCondition.clear;
      case 'cloudy':
        return WeatherCondition.cloudy;
      case 'rainy':
        return WeatherCondition.rainy;
      case 'stormy':
        return WeatherCondition.stormy;
      case 'snowy':
        return WeatherCondition.snowy;
      case 'foggy':
        return WeatherCondition.foggy;
      case 'sunrise':
        return WeatherCondition.sunrise;
      default:
        return WeatherCondition.cloudy;
    }
  }
}
