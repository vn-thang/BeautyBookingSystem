import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print("LOCATION ERROR: $e");
      return null;
    }
  }

  Future<String> getAddress(double lat, double lon) async {
    try {

      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json"
      );

      final response = await http.get(url, headers: {
        "User-Agent": "beauty-booking-app"
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return data["display_name"] ?? "Unknown location";
      }

      return "Unknown location";

    } catch (e) {
      print("GEOCODING ERROR: $e");
      return "Unknown location";
    }
  }
}