import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';

class DetailsScreen extends StatefulWidget {
  final String cityName;

  const DetailsScreen({Key? key, required this.cityName}) : super(key: key);

  @override
  _DetailsScreenState createState() {

    return _DetailsScreenState();
  }
}

class _DetailsScreenState extends State<DetailsScreen> {
  late String formattedTime;
  double temperature = 0.0;
  String weather = "Loading...";
  int humidity = 0;
  List<dynamic> hourlyForecast = [];

  @override
  void initState() {
    super.initState();
    assert(widget.cityName.isNotEmpty, "City field cannot be empty!");
    _updateTime();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
    fetchWeather();
    fetchHourlyForecast().then((data) {
      setState(() {
        hourlyForecast = data;
      });
    });
  }

  void _updateTime() {
    DateTime now = DateTime.now().toUtc().add(Duration(hours: 3));
    setState(() {
      formattedTime = DateFormat('HH:mm:ss').format(now);
    });
  }

  Future<void> fetchWeather() async {
    final apiKey = "31450a1bb22289f371545151d8e479d7";
    final city = widget.cityName;

    if (city.isEmpty) {
      print("ERROR: City field cannot be empty!");
      return;
    }

    final url = Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data == null || data["main"] == null) {
          print("Data returned from the API is NULL!");
          return;
        }

        body: weather == "Loading..."
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Text("$temperature°C"),
            Text(weather),
            Text("Nem: $humidity%"),
          ],
        );


    setState(() {
      temperature = (data["main"]["temp"] as num).toDouble();
      weather = data["weather"][0]["description"];
      humidity = data["main"]["humidity"];
        });
      } else {
        print("API error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<List<dynamic>> fetchHourlyForecast() async {
    final apiKey = "31450a1bb22289f371545151d8e479d7";
    final city = widget.cityName;
    final url = Uri.parse("https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["list"].take(6).toList(); // İlk 5 saatlik tahmini al
      } else {
        print("API Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  IconData getWeatherIcon(String weather) {
    if (weather.contains("sun")) return Icons.wb_sunny;
    if (weather.contains("cloud")) return Icons.cloud;
    if (weather.contains("rain")) return Icons.water_drop;
    if (weather.contains("snow")) return Icons.ac_unit;
    return Icons.wb_cloudy;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    if (weather.contains('sun')) {
      backgroundColor = Colors.amberAccent;
    } else if (weather.contains('cloud')) {
      backgroundColor = Colors.grey;
    } else if (weather.contains('rain')) {
      backgroundColor = Colors.blue;
      } else if (weather.contains('snow')) {
      backgroundColor = Colors.blueGrey;
    } else {
      backgroundColor = Colors.white;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: Text(widget.cityName), backgroundColor: Colors.amberAccent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              getWeatherIcon(weather.toLowerCase()),
              size: 50,
              color: Colors.white,
            ),
            Text(
              widget.cityName,
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
            ),
            SizedBox(height: 20),
            Text(
              "Temperature: ${temperature.toStringAsFixed(1)}°C",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Text(
              "Weather: $weather",
              style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
            ),
            Text(
              "Humidity: $humidity%",
              style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 30),
            Icon(
              Icons.access_time,
              size: 50,
              color: Colors.blueGrey,
            ),
            SizedBox(height: 10),
            Text(
              "Time: $formattedTime",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            SizedBox(height: 30),
            Text(
              "Hourly Forecast:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourlyForecast.length,
                itemBuilder: (context, index) {
                  var hourData = hourlyForecast[index];
                  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(hourData["dt"] * 1000);
                  String formattedHour = DateFormat('HH:mm').format(dateTime);
                  double temp = (hourData["main"]["temp"] as num).toDouble();
                  String weatherDesc = hourData["weather"][0]["description"];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(formattedHour, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Icon(getWeatherIcon(weatherDesc), size: 40, color: Colors.blueGrey),
                        Text("${temp.toStringAsFixed(1)}°C", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
