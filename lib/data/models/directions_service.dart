import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moonhike/imports.dart';

class DirectionsService {
  final String apiKey;

  DirectionsService() : apiKey = ApiKeys.googleMapsApiKey;

  Future<Map<String, dynamic>?> getRouteInfo(LatLng origin, LatLng destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=walking&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK') {
          return {
            'duration': data['routes'][0]['legs'][0]['duration']['text'],
            'distance': data['routes'][0]['legs'][0]['distance']['text'],
          };
        }
      } else {
        print('Error en la API de Directions: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
    return null;
  }
}