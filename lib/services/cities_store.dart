import 'package:flutter/foundation.dart';
import '../presentation/manage_cities_screen/manage_cities_screen.dart';
import '../presentation/weather_home_screen/weather_home_screen.dart';

/// Singleton store that holds the shared cities list and current city index.
/// Both WeatherHomeScreen and ManageCitiesScreen read/write from this store.
class CitiesStore extends ChangeNotifier {
  static final CitiesStore _instance = CitiesStore._internal();
  factory CitiesStore() => _instance;
  CitiesStore._internal();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  final List<CityData> _cities = [
    CityData(
      id: 'city_001',
      name: 'La Ceiba',
      country: 'HN',
      countryFull: 'Honduras',
      temperature: 24,
      condition: 'Chubascos',
      weatherCondition: WeatherCondition.rainy,
      high: 26,
      low: 21,
      humidity: 82,
      isCurrentLocation: true,
      timeZone: 'GMT-6',
      localTime: '17:22',
      feelsLike: 27,
      windSpeed: 18,
      windDirection: 'NE',
      pressure: 1012,
      visibility: 8.5,
      cloudCover: 85,
      latitude: 15.7835,
      longitude: -86.7897,
    ),
    CityData(
      id: 'city_002',
      name: 'Tegucigalpa',
      country: 'HN',
      countryFull: 'Honduras',
      temperature: 19,
      condition: 'Parcialmente nublado',
      weatherCondition: WeatherCondition.cloudy,
      high: 22,
      low: 14,
      humidity: 61,
      isCurrentLocation: false,
      timeZone: 'GMT-6',
      localTime: '17:22',
      feelsLike: 18,
      windSpeed: 12,
      windDirection: 'N',
      pressure: 1015,
      visibility: 10.0,
      cloudCover: 55,
      latitude: 14.0818,
      longitude: -87.2068,
    ),
    CityData(
      id: 'city_003',
      name: 'Ciudad de México',
      country: 'MX',
      countryFull: 'México',
      temperature: 21,
      condition: 'Despejado',
      weatherCondition: WeatherCondition.clear,
      high: 24,
      low: 15,
      humidity: 48,
      isCurrentLocation: false,
      timeZone: 'GMT-6',
      localTime: '17:22',
      feelsLike: 20,
      windSpeed: 10,
      windDirection: 'SW',
      pressure: 1018,
      visibility: 12.0,
      cloudCover: 10,
      latitude: 19.4326,
      longitude: -99.1332,
    ),
    CityData(
      id: 'city_004',
      name: 'Bogotá',
      country: 'CO',
      countryFull: 'Colombia',
      temperature: 14,
      condition: 'Lluvia ligera',
      weatherCondition: WeatherCondition.rainy,
      high: 16,
      low: 10,
      humidity: 77,
      isCurrentLocation: false,
      timeZone: 'GMT-5',
      localTime: '18:22',
      feelsLike: 12,
      windSpeed: 8,
      windDirection: 'SE',
      pressure: 1010,
      visibility: 7.0,
      cloudCover: 80,
      latitude: 4.7110,
      longitude: -74.0721,
    ),
    CityData(
      id: 'city_005',
      name: 'Madrid',
      country: 'ES',
      countryFull: 'España',
      temperature: 12,
      condition: 'Nublado',
      weatherCondition: WeatherCondition.cloudy,
      high: 15,
      low: 8,
      humidity: 65,
      isCurrentLocation: false,
      timeZone: 'GMT+1',
      localTime: '00:22',
      feelsLike: 10,
      windSpeed: 15,
      windDirection: 'W',
      pressure: 1020,
      visibility: 9.0,
      cloudCover: 70,
      latitude: 40.4168,
      longitude: -3.7038,
    ),
  ];

  List<CityData> get cities => List.unmodifiable(_cities);

  CityData get currentCity => _cities.isNotEmpty
      ? _cities[_currentIndex.clamp(0, _cities.length - 1)]
      : _cities.first;

  void setCurrentIndex(int index) {
    if (index < 0 || index >= _cities.length) return;
    _currentIndex = index;
    // Mark isCurrentLocation
    for (int i = 0; i < _cities.length; i++) {
      _cities[i].isCurrentLocation = i == index;
    }
    notifyListeners();
  }

  void setCurrentCityById(String id) {
    final index = _cities.indexWhere((c) => c.id == id);
    if (index != -1) setCurrentIndex(index);
  }

  void addCity(CityData city) {
    final exists = _cities.any((c) => c.id == city.id);
    if (!exists) {
      _cities.add(city);
      notifyListeners();
    }
  }

  void removeCity(String id) {
    final index = _cities.indexWhere((c) => c.id == id);
    if (index == -1) return;
    _cities.removeAt(index);
    if (_currentIndex >= _cities.length) {
      _currentIndex = (_cities.length - 1).clamp(0, _cities.length - 1);
    }
    notifyListeners();
  }
}
