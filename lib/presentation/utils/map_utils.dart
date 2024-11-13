//import 'package:flutter/services.dart' show rootBundle;
import 'package:moonhike/imports.dart';

class MapUtils {
  static Future<void> setMapController(
      Completer<GoogleMapController> mapControllerCompleter,
      GoogleMapController controller,
      ) async {
    if (!mapControllerCompleter.isCompleted) {
      mapControllerCompleter.complete(controller);
    }

    // Cargar y aplicar el estilo de mapa
    _loadMapStyle(controller);
  }

  static Future<void> _loadMapStyle(GoogleMapController controller) async {
    try {
      String style = await rootBundle.loadString('assets/map_styles/map_style.json');
      controller.setMapStyle(style);
    } catch (e) {
      print("Error al cargar el estilo del mapa: $e");
    }
  }

  static void addMarkerForSelectedLocation({
    required Set<Marker> markers,
    required GoogleMapController controller,
    required LatLng location,
  }) {
    markers.add(Marker(
      markerId: MarkerId('selectedLocation'),
      position: location,
      infoWindow: InfoWindow(title: 'Ubicación seleccionada'),
    ));
    controller.animateCamera(CameraUpdate.newLatLng(location));
  }
}