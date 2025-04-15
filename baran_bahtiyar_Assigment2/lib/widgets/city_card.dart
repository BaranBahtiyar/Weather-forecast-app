import 'package:flutter/material.dart';
import '../models/city.dart';
import '../screens/details_screen.dart'; // Yeni eklenen sayfa

class CityCard extends StatelessWidget {
  final City city;
  final VoidCallback? onTap;

  const CityCard({Key? key, required this.city, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(city.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text('${city.weather} - ${city.temperature}°C'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailsScreen(cityName: city.name)),
          );
        },
      ),
    );
  }
}
