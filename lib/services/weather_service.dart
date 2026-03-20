import 'dart:convert';

import 'package:dio/dio.dart';

import '../presentation/manage_cities_screen/manage_cities_screen.dart';
import '../presentation/weather_home_screen/weather_home_screen.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Search cities globally using Open-Meteo Geocoding API (free, no key needed)
  Future<List<GeocodingResult>> searchCities(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final response = await _dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {
          'name': query.trim(),
          'count': 10,
          'language': 'es',
          'format': 'json',
        },
      );
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;
      if (results == null) return [];
      return results
          .map((r) => GeocodingResult.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Fetch current weather for a lat/lon using Open-Meteo Weather API
  Future<CityData?> fetchWeatherForLocation({
    required double latitude,
    required double longitude,
    required String cityName,
    required String countryCode,
    required String countryFull,
    required String timezone,
    bool isCurrentLocation = false,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': [
            'temperature_2m',
            'apparent_temperature',
            'relative_humidity_2m',
            'weather_code',
            'wind_speed_10m',
            'wind_direction_10m',
            'surface_pressure',
            'visibility',
            'cloud_cover',
          ].join(','),
          'daily': [
            'temperature_2m_max',
            'temperature_2m_min',
            'precipitation_probability_max',
          ].join(','),
          'timezone': timezone.isNotEmpty ? timezone : 'auto',
          'forecast_days': 1,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>;
      final daily = data['daily'] as Map<String, dynamic>;

      final temp = (current['temperature_2m'] as num).round();
      final feelsLike = (current['apparent_temperature'] as num).round();
      final humidity = (current['relative_humidity_2m'] as num).round();
      final windSpeed = (current['wind_speed_10m'] as num).round();
      final windDir = _windDirection(
        (current['wind_direction_10m'] as num).toDouble(),
      );
      final pressure = (current['surface_pressure'] as num).round();
      final cloudCover = (current['cloud_cover'] as num).round();
      final visibilityRaw = current['visibility'] as num?;
      final visibility = visibilityRaw != null
          ? (visibilityRaw.toDouble() / 1000.0)
          : 10.0;

      final weatherCode = (current['weather_code'] as num).toInt();
      final condition = _weatherConditionFromCode(weatherCode);
      final conditionText = _conditionTextFromCode(weatherCode);

      final dailyMaxList = daily['temperature_2m_max'] as List<dynamic>;
      final dailyMinList = daily['temperature_2m_min'] as List<dynamic>;
      final high = dailyMaxList.isNotEmpty
          ? (dailyMaxList[0] as num).round()
          : temp + 2;
      final low = dailyMinList.isNotEmpty
          ? (dailyMinList[0] as num).round()
          : temp - 3;

      // Compute local time from timezone offset
      final localTime = _localTimeFromTimezone(timezone);

      return CityData(
        id: 'city_${cityName.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
        name: cityName,
        country: countryCode,
        countryFull: countryFull,
        temperature: temp,
        condition: conditionText,
        weatherCondition: condition,
        high: high,
        low: low,
        humidity: humidity,
        isCurrentLocation: isCurrentLocation,
        timeZone: timezone,
        localTime: localTime,
        feelsLike: feelsLike,
        windSpeed: windSpeed,
        windDirection: windDir,
        pressure: pressure,
        visibility: visibility,
        cloudCover: cloudCover,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (_) {
      return null;
    }
  }

  String _windDirection(double degrees) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return dirs[index];
  }

  String _localTimeFromTimezone(String timezone) {
    try {
      final now = DateTime.now().toUtc();
      // Simple offset estimation — just show UTC time formatted
      final hour = now.hour.toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '--:--';
    }
  }

  WeatherCondition _weatherConditionFromCode(int code) {
    if (code == 0) return WeatherCondition.clear;
    if (code <= 3) return WeatherCondition.cloudy;
    if (code <= 49) return WeatherCondition.foggy;
    if (code <= 67) return WeatherCondition.rainy;
    if (code <= 77) return WeatherCondition.snowy;
    if (code <= 82) return WeatherCondition.rainy;
    return WeatherCondition.stormy;
  }

  String _conditionTextFromCode(int code) {
    if (code == 0) return 'Despejado';
    if (code == 1) return 'Principalmente despejado';
    if (code == 2) return 'Parcialmente nublado';
    if (code == 3) return 'Nublado';
    if (code <= 9) return 'Neblina';
    if (code <= 19) return 'Niebla';
    if (code <= 29) return 'Tormenta eléctrica';
    if (code <= 39) return 'Nieve ligera';
    if (code <= 49) return 'Niebla';
    if (code == 51) return 'Llovizna ligera';
    if (code == 53) return 'Llovizna moderada';
    if (code == 55) return 'Llovizna intensa';
    if (code <= 57) return 'Llovizna helada';
    if (code == 61) return 'Lluvia ligera';
    if (code == 63) return 'Lluvia moderada';
    if (code == 65) return 'Lluvia intensa';
    if (code <= 67) return 'Lluvia helada';
    if (code <= 69) return 'Nieve ligera';
    if (code <= 77) return 'Nieve';
    if (code == 80) return 'Chubascos ligeros';
    if (code == 81) return 'Chubascos';
    if (code == 82) return 'Chubascos intensos';
    if (code <= 84) return 'Nieve con lluvia';
    if (code <= 86) return 'Nieve intensa';
    if (code <= 94) return 'Tormenta eléctrica';
    return 'Tormenta con granizo';
  }
}

class GeocodingResult {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String countryCode;
  final String country;
  final String timezone;
  final String? admin1;

  GeocodingResult({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.countryCode,
    required this.country,
    required this.timezone,
    this.admin1,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      countryCode: json['country_code'] as String? ?? '',
      country: json['country'] as String? ?? '',
      timezone: json['timezone'] as String? ?? 'auto',
      admin1: json['admin1'] as String?,
    );
  }

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      return '$name, $admin1';
    }
    return name;
  }
}
