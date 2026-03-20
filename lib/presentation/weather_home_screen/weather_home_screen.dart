import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/cities_store.dart';
import '../../theme/app_theme.dart';
import '../manage_cities_screen/manage_cities_screen.dart';
import './widgets/daily_forecast_widget.dart';
import './widgets/hourly_forecast_widget.dart';
import './widgets/lifestyle_tips_widget.dart';
import './widgets/rain_alert_widget.dart';
import './widgets/sunrise_sunset_widget.dart';
import './widgets/weather_background_widget.dart';
import './widgets/weather_detail_grid_widget.dart';
import './widgets/weather_header_widget.dart';
import './widgets/weather_hero_widget.dart';

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  late PageController _pageController;
  final CitiesStore _store = CitiesStore();

  bool _isNight = false;
  bool _isLoading = false;
  int _currentPageIndex = 0;

  // Track previous condition for background transition
  WeatherCondition? _previousCondition;

  @override
  void initState() {
    super.initState();

    _currentPageIndex = _store.currentIndex;
    _pageController = PageController(initialPage: _currentPageIndex);

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentFadeAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );

    _contentSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    _determineTimeOfDay();
    _contentController.forward();

    _store.addListener(_onStoreChanged);
  }

  void _onStoreChanged() {
    if (!mounted) return;
    final newIndex = _store.currentIndex;
    if (newIndex != _currentPageIndex) {
      setState(() => _currentPageIndex = newIndex);
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _animateContent();
    }
  }

  void _determineTimeOfDay() {
    final hour = DateTime.now().hour;
    setState(() {
      _isNight = hour < 6 || hour >= 20;
    });
  }

  void _animateContent() {
    _contentController.reset();
    _contentController.forward();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _isLoading = false);
  }

  Future<void> _openManageCities() async {
    await Navigator.pushNamed(context, AppRoutes.manageCitiesScreen);
    // After returning, sync page controller to store's current index
    if (mounted) {
      final newIndex = _store.currentIndex;
      if (newIndex != _currentPageIndex) {
        setState(() => _currentPageIndex = newIndex);
        _pageController.jumpToPage(newIndex);
        _animateContent();
      } else {
        setState(() {});
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPageIndex = index);
    _store.setCurrentIndex(index);
    _animateContent();
  }

  List<Color> _backgroundGradientForCity(CityData city) {
    if (_isNight) return AppTheme.clearNightGradient;
    switch (city.weatherCondition) {
      case WeatherCondition.clear:
        return AppTheme.clearDayGradient;
      case WeatherCondition.cloudy:
        return AppTheme.cloudyGradient;
      case WeatherCondition.rainy:
        return AppTheme.rainyGradient;
      case WeatherCondition.stormy:
        return AppTheme.stormyGradient;
      case WeatherCondition.snowy:
        return AppTheme.snowGradient;
      case WeatherCondition.foggy:
        return AppTheme.fogGradient;
      case WeatherCondition.sunrise:
        return AppTheme.sunriseGradient;
    }
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _backgroundController.dispose();
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cities = _store.cities;
    if (cities.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1628),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final safeIndex = _currentPageIndex.clamp(0, cities.length - 1);
    final currentCity = cities[safeIndex];
    final gradient = _backgroundGradientForCity(currentCity);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Dynamic animated background — transitions with city condition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: WeatherBackgroundWidget(
              key: ValueKey(
                '${currentCity.id}_${currentCity.weatherCondition.name}',
              ),
              condition: currentCity.weatherCondition,
              isNight: _isNight,
              gradient: gradient,
              controller: _backgroundController,
            ),
          ),

          // PageView for swipe between cities
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Swipeable city pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      return _CityWeatherPage(
                        city: city,
                        isNight: _isNight,
                        onMenuTap: _openManageCities,
                        onRefresh: _handleRefresh,
                        contentFadeAnimation: _contentFadeAnimation,
                        contentSlideAnimation: _contentSlideAnimation,
                        isActive: index == safeIndex,
                      );
                    },
                  ),
                ),

                // Page indicator dots
                if (cities.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PageIndicator(
                      count: cities.length,
                      currentIndex: safeIndex,
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

// ─── Page Indicator ──────────────────────────────────────────────────────────

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withAlpha(77),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ─── Single City Weather Page ─────────────────────────────────────────────────

class _CityWeatherPage extends StatelessWidget {
  final CityData city;
  final bool isNight;
  final VoidCallback onMenuTap;
  final Future<void> Function() onRefresh;
  final Animation<double> contentFadeAnimation;
  final Animation<Offset> contentSlideAnimation;
  final bool isActive;

  const _CityWeatherPage({
    required this.city,
    required this.isNight,
    required this.onMenuTap,
    required this.onRefresh,
    required this.contentFadeAnimation,
    required this.contentSlideAnimation,
    required this.isActive,
  });

  List<Map<String, dynamic>> _buildHourlyData() {
    final now = DateTime.now();
    final condition = city.weatherCondition;
    final baseTemp = city.temperature;
    final conditions = List.generate(12, (i) {
      if (i < 4) return condition;
      if (i < 8) return WeatherCondition.cloudy;
      return WeatherCondition.clear;
    });
    final temps = List.generate(
      12,
      (i) => baseTemp + (i < 6 ? -1 : 1) * (i % 3),
    );
    final probs = [90, 85, 70, 88, 92, 75, 60, 20, 10, 5, 15, 30];

    return List.generate(12, (i) {
      final time = now.add(Duration(hours: i));
      return {
        'time': i == 0 ? 'Ahora' : '${time.hour.toString().padLeft(2, '0')}:00',
        'condition': conditions[i],
        'temperature': temps[i],
        'rainProbability': probs[i],
        'isNow': i == 0,
      };
    });
  }

  List<Map<String, dynamic>> _buildDailyData() {
    final dayNames = ['Hoy', 'Mañana', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final condition = city.weatherCondition;
    final baseHigh = city.high;
    final baseLow = city.low;
    final conditions = [
      condition,
      WeatherCondition.cloudy,
      WeatherCondition.clear,
      WeatherCondition.clear,
      WeatherCondition.cloudy,
      condition,
      WeatherCondition.cloudy,
    ];
    final highs = List.generate(7, (i) => baseHigh + (i % 3) - 1);
    final lows = List.generate(7, (i) => baseLow + (i % 2) - 1);
    final probs = [87, 45, 10, 5, 35, 75, 40];

    return List.generate(
      7,
      (i) => {
        'day': dayNames[i],
        'condition': conditions[i],
        'high': highs[i],
        'low': lows[i],
        'rainProbability': probs[i],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return FadeTransition(
      opacity: contentFadeAnimation,
      child: SlideTransition(
        position: contentSlideAnimation,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          color: Colors.white,
          backgroundColor: AppTheme.skyBlue,
          child: isTablet
              ? _buildTabletLayout(context)
              : _buildPhoneLayout(context),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: WeatherHeaderWidget(
            city: city.name,
            country: city.country,
            onMenuTap: onMenuTap,
            onSettingsTap: () {},
          ),
        ),
        SliverToBoxAdapter(
          child: WeatherHeroWidget(
            temperature: city.temperature,
            condition: city.condition,
            high: city.high,
            low: city.low,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: RainAlertWidget(
              condition: city.weatherCondition,
              probability: city.humidity > 70 ? 87 : 30,
              duration: 6,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: HourlyForecastWidget(hourlyData: _buildHourlyData()),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DailyForecastWidget(dailyData: _buildDailyData()),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: WeatherDetailGridWidget(
              feelsLike: city.feelsLike,
              humidity: city.humidity,
              windSpeed: city.windSpeed,
              windDirection: city.windDirection,
              uvIndex: 3,
              pressure: city.pressure,
              visibility: city.visibility,
              dewPoint: (city.temperature - 5).clamp(0, 40),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const SunriseSunsetWidget(
              sunriseTime: '05:48',
              sunsetTime: '18:23',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            child: LifestyleTipsWidget(
              condition: city.weatherCondition,
              uvIndex: 3,
              humidity: city.humidity,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: WeatherHeaderWidget(
            city: city.name,
            country: city.country,
            onMenuTap: onMenuTap,
            onSettingsTap: () {},
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      WeatherHeroWidget(
                        temperature: city.temperature,
                        condition: city.condition,
                        high: city.high,
                        low: city.low,
                      ),
                      const SizedBox(height: 12),
                      RainAlertWidget(
                        condition: city.weatherCondition,
                        probability: city.humidity > 70 ? 87 : 30,
                        duration: 6,
                      ),
                      const SizedBox(height: 12),
                      HourlyForecastWidget(hourlyData: _buildHourlyData()),
                      const SizedBox(height: 12),
                      const SunriseSunsetWidget(
                        sunriseTime: '05:48',
                        sunsetTime: '18:23',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      DailyForecastWidget(dailyData: _buildDailyData()),
                      const SizedBox(height: 12),
                      WeatherDetailGridWidget(
                        feelsLike: city.feelsLike,
                        humidity: city.humidity,
                        windSpeed: city.windSpeed,
                        windDirection: city.windDirection,
                        uvIndex: 3,
                        pressure: city.pressure,
                        visibility: city.visibility,
                        dewPoint: (city.temperature - 5).clamp(0, 40),
                      ),
                      const SizedBox(height: 12),
                      LifestyleTipsWidget(
                        condition: city.weatherCondition,
                        uvIndex: 3,
                        humidity: city.humidity,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum WeatherCondition { clear, cloudy, rainy, stormy, snowy, foggy, sunrise }
