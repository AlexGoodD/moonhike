//Este archivo gestiona las solicitudes a la API de Google Directions, extrayendo las rutas con la distancia, duración y puntos.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moonhike/imports.dart';

class RouteService {
  final String apiKey;

  RouteService() : apiKey = ApiKeys.googleMapsApiKey;

  Future<List<List<LatLng>>> getRoutes(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=walking&alternatives=true&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        List<List<LatLng>> routes = [];
        for (var route in data['routes']) {
          routes.add(_decodePolyline(route['overview_polyline']['points']));
        }
        return routes;
      } else {
        print('Error en la respuesta de la API: ${data['status']}');
        print('Mensaje de error de la API: ${data['error_message'] ?? "No disponible"}');
        return [];
      }
    } else {
      print('Error al hacer la solicitud: ${response.statusCode}');
      return [];
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}