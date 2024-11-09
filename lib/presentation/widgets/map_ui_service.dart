import 'package:moonhike/imports.dart';

class MapUIService {
  final CalculateDistanceUseCase calculateDistanceUseCase;

  MapUIService({required this.calculateDistanceUseCase});

  /// Actualiza los marcadores y círculos en el mapa basándose en los reportes cercanos a la ruta seleccionada.
  ///
  /// Parámetros:
  /// - [snapshot]: Los datos de reportes obtenidos de Firestore.
  /// - [markers]: Un Set donde se almacenan los marcadores del mapa.
  /// - [circles]: Un Set donde se almacenan los círculos de áreas peligrosas en el mapa.
  /// - [routes]: Lista de listas de puntos [LatLng] que representan rutas.
  /// - [selectedRouteIndex]: El índice de la ruta actualmente seleccionada.
  /// - [updateUI]: Callback para actualizar la interfaz de usuario.
  void updateMarkersAndCircles(
      QuerySnapshot snapshot,
      Set<Marker> markers,
      Set<Circle> circles,
      List<List<LatLng>> routes,
      int selectedRouteIndex,
      VoidCallback updateUI,
      ) {
    markers.clear();
    circles.clear();

    // Verificar que la ruta seleccionada esté definida
    if (routes.isEmpty || selectedRouteIndex >= routes.length) return;

    List<LatLng> selectedRoute = routes[selectedRouteIndex];

    for (var doc in snapshot.docs) {
      GeoPoint location = doc['location'];
      LatLng reportPosition = LatLng(location.latitude, location.longitude);

      // Verifica si el reporte está cerca de la ruta seleccionada
      if (_isNearRoute(reportPosition, selectedRoute)) {
        String reportType = doc['type'];
        String reportUser = doc['user'] ?? 'Usuario desconocido';
        DateTime reportTimestamp = (doc['timestamp'] as Timestamp).toDate();
        String reportDate = '${reportTimestamp.day}/${reportTimestamp.month}/${reportTimestamp.year}';
        String reportTime = '${reportTimestamp.hour}:${reportTimestamp.minute}';

        // Determina el color del marcador y del círculo basado en el tipo de reporte
        double markerHue;
        Color circleColor;

        if (reportType == 'Mala iluminación') {
          markerHue = BitmapDescriptor.hueYellow;
          circleColor = const Color.fromARGB(255, 206, 198, 124).withOpacity(0.3);
        } else if (reportType == 'Inseguridad') {
          markerHue = BitmapDescriptor.hueViolet;
          circleColor = const Color.fromARGB(255, 101, 39, 176).withOpacity(0.3);
        } else {
          markerHue = BitmapDescriptor.hueRed;
          circleColor = Colors.red.withOpacity(0.3);
        }

        Marker marker = Marker(
          markerId: MarkerId('report_${doc.id}'),
          position: reportPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
          infoWindow: InfoWindow(
            title: reportType,
            snippet: 'Creado por: $reportUser\nFecha: $reportDate\nHora: $reportTime',
          ),
        );

        Circle circle = Circle(
          circleId: CircleId('danger_area_${doc.id}'),
          center: reportPosition,
          radius: 20,
          fillColor: circleColor,
          strokeColor: circleColor.withOpacity(0.6),
          strokeWidth: 2,
        );

        markers.add(marker);
        circles.add(circle);
      }
    }

    // Llamar al callback para actualizar la UI después de cambiar los marcadores y círculos
    updateUI();
  }

  /// Verifica si un punto de reporte está cerca de la ruta seleccionada.
  ///
  /// Parámetros:
  /// - [reportPosition]: La posición del reporte a verificar.
  /// - [route]: La lista de puntos [LatLng] de la ruta seleccionada.
  ///
  /// Retorna `true` si el punto del reporte está cerca de algún punto de la ruta,
  /// `false` en caso contrario.
  bool _isNearRoute(LatLng reportPosition, List<LatLng> route) {
    const double proximityThreshold = 50.0; // Distancia en metros para considerar proximidad
    for (var point in route) {
      if (calculateDistanceUseCase.execute(reportPosition, point) <= proximityThreshold) {
        return true;
      }
    }
    return false;
  }
}