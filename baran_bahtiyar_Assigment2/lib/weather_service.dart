import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "31450a1bb22289f371545151d8e479d7";

  Future<Map<String, dynamic>> fetchWeather(String cityName) async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Weather data could not be fetched!");
    }
  }
}
