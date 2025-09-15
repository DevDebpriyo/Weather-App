import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // api key
  final _weatherService = WeatherService('f9231a4a730163b5f8b18f847d7c1895');
  Weather? _weather;
  String? _errorMessage;

  // fetch weather data
  _fetchWeather() async {
    try {
      // get the current city
      String cityName = await _weatherService.getCurrentCity();
      print('Detected city: $cityName');
      if (cityName.isEmpty) {
        setState(() {
          _errorMessage = 'Could not determine your city.';
        });
        return;
      }
      // fetch the weather data for the city
      final weather = await _weatherService.getWeather(cityName);
      print(
        'Weather data: city=${weather.cityName}, temp=${weather.temperature}',
      );
      setState(() {
        _weather = weather;
        _errorMessage = null;
      });
    } catch (e) {
      print('Error fetching weather data: $e');
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  // weather animations
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json'; // default animation
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/thundery.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thundery.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json'; // default animation
    }
  }

  // init state
  @override
  void initState() {
    super.initState();

    // fetch weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontFamily: 'HelveticaNowDisplay',
                ),
              ),
            ] else if (_weather == null) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Loading weather...',
                style: TextStyle(fontFamily: 'HelveticaNowDisplay'),
              ),
            ] else ...[
              // pin icon above city name
              const Icon(Icons.location_pin, color: Colors.redAccent, size: 32),
              const SizedBox(height: 4),
              // city name
              Text(
                _weather!.cityName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'HelveticaNowDisplay',
                ),
              ),

              // animation
              Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),

              // temperature
              Text(
                '${_weather!.temperature.round()}°'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontFamily: 'HelveticaNowDisplay',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
