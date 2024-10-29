import 'dart:async';
import 'dart:math' as math;
import 'package:moonhike/imports.dart';

class MapController {
  Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? controller;
  LatLng? currentPosition;
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  Set<Polyline> polylines = {};
  String? userEmail;
  StreamSubscription<Position>? positionStream;
  StreamSubscription<QuerySnapshot>? reportsSubscription; // Listener para cambios en Firestore
  List<List<LatLng>> routes = [];
  int selectedRouteIndex = 0;
  VoidCallback? updateUI; // Callback para actualizar la UI

  final BuildContext context;
  final RouteRepository routeRepository;

  MapController({required this.context, required this.routeRepository});

  void init() {
    _getUserEmail();
    _listenToReportChanges(); // Inicia el listener para los reportes
  }

  Future<void> _getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    userEmail = user?.email;
  }

  Future<void> startLocationUpdates(Function(LatLng) onPositionUpdate) async {
    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      currentPosition = LatLng(position.latitude, position.longitude);
      onPositionUpdate(currentPosition!);
    });
  }

  void dispose() {
    positionStream?.cancel();
    reportsSubscription?.cancel(); // Cancela la suscripción para los reportes
  }

  // Nueva función para definir el callback de actualización de UI
  void setUpdateUICallback(VoidCallback callback) {
    updateUI = callback;
  }

  Future<void> setMapController(GoogleMapController controller) async {
    this.controller = controller;
    if (!_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.complete(controller);
    }
  }

  Future<void> startRoutes(LatLng? destination) async {
    if (currentPosition == null || destination == null) return;
    routes = await getRoutes(currentPosition!, destination);
    int safestRouteIndex = _getSafestRouteIndex();
    polylines.clear();
    selectRoute(safestRouteIndex);
  }

  void selectRoute(int index) {
    selectedRouteIndex = index;
    polylines.clear();
    for (int i = 0; i < routes.length; i++) {
      polylines.add(Polyline(
        polylineId: PolylineId('route_$i'),
        points: routes[i],
        color: i == selectedRouteIndex ? Colors.blue : Colors.grey,
        width: 5,
      ));
    }

    // Llamar al callback para actualizar la UI
    updateUI?.call();
  }

  Future<void> createReport(String reportType, String note) async {
    if (currentPosition == null) return;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('reports').add({
      'user': userEmail,
      'location': GeoPoint(currentPosition!.latitude, currentPosition!.longitude),
      'timestamp': FieldValue.serverTimestamp(),
      'type': reportType, 
      'note': note, // Añadir la nota al reporte
    });

    // Actualiza los marcadores según el tipo de reporte
    _updateMarkersAndCircles(await firestore.collection('reports').get());
  }




  Future<List<List<LatLng>>> getRoutes(LatLng start, LatLng end) async {
    // Usar RouteRepository para obtener las rutas
    return await routeRepository.fetchRoutes(start, end);
  }

  Future<void> loadReports() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference reports = firestore.collection('reports');
    QuerySnapshot querySnapshot = await reports.get();

    _updateMarkersAndCircles(querySnapshot);
  }

  void _updateMarkersAndCircles(QuerySnapshot querySnapshot) {
    markers.clear();
    circles.clear();

    for (var doc in querySnapshot.docs) {
      GeoPoint location = doc['location'];
      LatLng reportPosition = LatLng(location.latitude, location.longitude);

      // Datos del reporte
      String reportType = doc['type'];
      String reportUser = doc['user'] ?? 'Usuario desconocido';
      DateTime reportTimestamp = (doc['timestamp'] as Timestamp).toDate();
      String reportDate = '${reportTimestamp.day}/${reportTimestamp.month}/${reportTimestamp.year}';
      String reportTime = '${reportTimestamp.hour}:${reportTimestamp.minute}'; // Asegúrate de que reportTime esté definido aquí
      String note = doc['note'] ?? ''; // Asegúrate de que note esté definido aquí

      // Configuración de colores para el marcador y círculo
      double markerHue;
      Color circleColor;

      if (reportType == 'mala iluminación') {
        markerHue = BitmapDescriptor.hueYellow;
        circleColor = const Color.fromARGB(255, 206, 198, 124).withOpacity(0.3);
      } else if (reportType == 'inseguridad') {
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
        onTap: () {
          showDialog(
            context: this.context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.zero,
                content: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título con fondo morado
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 94, 60, 229),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            reportType,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 19,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Información de usuario, fecha y nota
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Creado por',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(reportUser),
                            SizedBox(height: 8),
                            Text(
                              'Fecha y hora de creación',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('$reportDate $reportTime'),
                            SizedBox(height: 8),
                            if (note.isNotEmpty) ...[
                              Text(
                                'Nota',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(note),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      // Botón de cerrar
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'cerrar',
                            style: TextStyle(color: const Color.fromARGB(255, 94, 60, 229)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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

    updateUI?.call();
  }

  void _listenToReportChanges() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference reports = firestore.collection('reports');

    // Escucha cambios en tiempo real en la colección 'reports'
    reportsSubscription = reports.snapshots().listen((snapshot) {
      _updateMarkersAndCircles(snapshot);
    });
  }

  void addMarkerForSelectedLocation(LatLng location) {
    markers.add(Marker(
      markerId: MarkerId('selectedLocation'),
      position: location,
      infoWindow: InfoWindow(title: 'Ubicación seleccionada'),
    ));
    controller?.animateCamera(CameraUpdate.newLatLng(location));
  }

  int _getSafestRouteIndex() {
    if (routes.isEmpty) return 0;
    int minReports = double.maxFinite.toInt();
    int safestRouteIndex = 0;

    for (int i = 0; i < routes.length; i++) {
      int reportsCount = _countReportsNearRoute(routes[i]);
      if (reportsCount < minReports) {
        minReports = reportsCount;
        safestRouteIndex = i;
      }
    }
    return safestRouteIndex;
  }

  int _countReportsNearRoute(List<LatLng> route) {
    int reportCount = 0;
    const double proximityThreshold = 50.0;
    Set<String> countedMarkers = {};

    for (var point in route) {
      for (var marker in markers) {
        if (countedMarkers.contains(marker.markerId.value)) continue;
        if (_calculateDistance(point, marker.position) <= proximityThreshold) {
          reportCount++;
          countedMarkers.add(marker.markerId.value);
        }
      }
    }
    return reportCount;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000;
    double dLat = (point2.latitude - point1.latitude) * (math.pi / 180);
    double dLon = (point2.longitude - point1.longitude) * (math.pi / 180);
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(point1.latitude * (math.pi / 180)) *
            math.cos(point2.latitude * (math.pi / 180)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Eliminar UID de SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userUID');

      // Redirigir a la pantalla de inicio de sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error al cerrar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión')),
      );
    }
  }
}
