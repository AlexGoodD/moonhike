import 'package:moonhike/imports.dart';

class MapUIService {
  final CalculateDistanceUseCase calculateDistanceUseCase;
  final ReportsService reportsService = ReportsService();

  MapUIService({required this.calculateDistanceUseCase});

  /* Actualiza los marcadores y círculos en el mapa basándose en los reportes cercanos a la ruta seleccionada.
  Parámetros:
  [snapshot]: Los datos de reportes obtenidos de Firestore.
  [markers]: Un Set donde se almacenan los marcadores del mapa.
  [circles]: Un Set donde se almacenan los círculos de áreas peligrosas en el mapa.
  [routes]: Lista de listas de puntos [LatLng] que representan rutas.
  [selectedRouteIndex]: El índice de la ruta actualmente seleccionada.
  [updateUI]: Callback para actualizar la interfaz de usuario.
  Actualiza los marcadores y círculos en el mapa basándose en los reportes cercanos a la ruta seleccionada. */

  void updateMarkersAndCircles({
    required QuerySnapshot snapshot,
    required Set<Marker> markers,
    required Set<Circle> circles,
    required List<List<LatLng>> routes,
    required int selectedRouteIndex,
    required VoidCallback updateUI,
    required BuildContext context,
    required String userEmail,
    //required void Function(BuildContext, String) showDeleteDialog,
  }) {
    final Set<String> reportIds = snapshot.docs.map((doc) => doc.id).toSet();

    // Elimina marcadores y círculos de reportes que ya no existen
    markers.removeWhere((marker) => !reportIds.contains(marker.markerId.value.replaceFirst('report_', '')));
    circles.removeWhere((circle) => !reportIds.contains(circle.circleId.value.replaceFirst('danger_area_', '')));

    // Verificar que la ruta seleccionada esté definida
    if (routes.isEmpty || selectedRouteIndex >= routes.length) return;
    List<LatLng> selectedRoute = routes[selectedRouteIndex];

    // Agregar o actualizar solo los reportes actuales
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?; // Obtén los datos del documento de forma segura
      if (data == null) continue; // Si el documento no tiene datos, omitir

      GeoPoint location = data['location'];
      LatLng reportPosition = LatLng(location.latitude, location.longitude);

      // Verificar si el reporte está cerca de la ruta seleccionada
      if (!isNearRoute(reportPosition, selectedRoute)) {
        continue; // Si no está cerca, omitir
      }

      final String markerId = 'report_${doc.id}';
      String reportType = data['type'] ?? 'Reporte desconocido';
      String reportUser = data.containsKey('user') ? data['user'] : 'Noticia'; // Asigna "Noticia" si 'user' no existe

      double markerHue;
      Color circleColor;

      // Define el color del marcador y círculo según el tipo de reporte
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

      // Añade el marcador
      markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: reportPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
          infoWindow: InfoWindow(
            title: reportType,
            snippet: 'Creado por: $reportUser',
          ),
        ),
      );

      // Añade el círculo de área de riesgo
      circles.add(
        Circle(
          circleId: CircleId('danger_area_${doc.id}'),
          center: reportPosition,
          radius: 20,
          fillColor: circleColor,
          strokeColor: circleColor.withOpacity(0.6),
          strokeWidth: 2,
        ),
      );
    }
    updateUI();
  }

  /* Verifica si un punto de reporte está cerca de la ruta seleccionada.
  Parámetros: [reportPosition]: Reporte, [route]: Ruta, Retorna `true`
  si el punto del reporte está en la ruta y false en  caso contrario*/

  bool isNearRoute(LatLng reportPosition, List<LatLng> route) {
    const double proximityThreshold = 50.0; // Distancia en metros para considerar proximidad
    for (var point in route) {
      if (calculateDistanceUseCase.execute(reportPosition, point) <= proximityThreshold) {
        print('El reporte está cerca de la ruta.');
        return true;
      }
    }
    print('El reporte no está cerca de la ruta.');
    return false;
  }
}

