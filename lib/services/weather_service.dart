import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    try {
      // get permission from user
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      // fetch the current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Position: lat=${position.latitude}, lon=${position.longitude}');
      // Try Flutter geocoding first
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        print('Placemarks: $placemarks');
        String? city = placemarks.isNotEmpty ? placemarks[0].locality : null;
        print('Reverse geocoded city: $city');
        if (city != null && city.isNotEmpty) {
          return city;
        }
      } catch (e) {
        print('Flutter geocoding failed: $e');
      }
      // Fallback: Use OpenStreetMap Nominatim API
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=10&addressdetails=1',
        );
        final response = await http.get(
          url,
          headers: {'User-Agent': 'weather_app_flutter/1.0 (your@email.com)'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final address = data['address'];
          final city =
              address['city'] ??
              address['town'] ??
              address['village'] ??
              address['state'] ??
              '';
          print('Nominatim: $city');
          return city;
        } else {
          print('Nominatim API error: ${response.statusCode}');
        }
      } catch (e) {
        print('Nominatim geocoding failed: $e');
      }
      return '';
    } catch (e) {
      print('Error in getCurrentCity: $e');
      return '';
    }
  }
}
