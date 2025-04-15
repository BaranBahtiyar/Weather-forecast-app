import 'package:flutter/material.dart';
import '../weather_service.dart';
import 'details_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, String>> cities = [
    {"name": "Istanbul"},
    {"name": "Ankara"},
    {"name": "İzmir"},
    {"name": "Aydın"},
    {"name": "Bursa"},
    {"name": "Antalya"},
  ];

  List<Map<String, dynamic>> weatherData = []; // Hava durumu verileri

  @override
  void initState() {
    super.initState();
    fetchWeatherData(); // Uygulama açılınca API'den verileri çek
  }

  Future<void> fetchWeatherData() async {
    List<Map<String, dynamic>> tempList = [];

    for (Map<String, String> cityData in cities) {
      try {
        var data = await WeatherService().fetchWeather(cityData["name"]!);
        tempList.add(data);
            } catch (e) {
        print("An error occured: $e"); // Hata logları için
      }
    }
    setState(() {
      weatherData = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Weather forecast"), backgroundColor: Colors.amberAccent,),
      body: weatherData.isEmpty
          ? Center(child: CircularProgressIndicator()) // Veriler yüklenirken göster
          : ListView.builder(
        itemCount: weatherData.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(weatherData[index]["name"]), // Şehir adı
            subtitle: Text(
                "Temperature: ${weatherData[index]["main"]["temp"]}°C - Humidity: ${weatherData[index]["main"]["humidity"]}%"), // Sıcaklık bilgisi
            trailing: Image.network(
                "https://openweathermap.org/img/w/${weatherData[index]["weather"][0]["icon"]}.png"), // Hava durumu ikonu
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(
                    cityName: weatherData[index]["name"],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
