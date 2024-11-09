//Este archivo contiene los permisos necesarios para la utilidades de locación

import 'package:moonhike/imports.dart';

class LocationService {
  LatLng? currentPosition;
  StreamSubscription<Position>? positionStream;

  // Inicia la actualización de la ubicación
  Future<void> startLocationUpdates(Function(LatLng) onPositionUpdate) async {
    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      currentPosition = LatLng(position.latitude, position.longitude);
      onPositionUpdate(currentPosition!);
    });
  }

  // Cancela la suscripción de la actualización de la ubicación
  void stopLocationUpdates() {
    positionStream?.cancel();
  }
}