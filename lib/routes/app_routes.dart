import 'package:flutter/material.dart';

import '../presentation/manage_cities_screen/manage_cities_screen.dart';
import '../presentation/weather_home_screen/weather_home_screen.dart';

class AppRoutes {
  static const String initial = '/weather-home-screen';
  static const String weatherHomeScreen = '/weather-home-screen';
  static const String manageCitiesScreen = '/manage-cities-screen';

  static Map<String, WidgetBuilder> routes = {
    weatherHomeScreen: (context) => const WeatherHomeScreen(),
    manageCitiesScreen: (context) => const ManageCitiesScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case weatherHomeScreen:
        return _buildRoute(const WeatherHomeScreen(), settings);
      case manageCitiesScreen:
        return _buildRoute(const ManageCitiesScreen(), settings);
      default:
        return _buildRoute(const WeatherHomeScreen(), settings);
    }
  }

  static PageRoute _buildRoute(Widget screen, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
