import 'dart:async';
import 'package:moonhike/imports.dart';

class MapController {
  Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? controller;
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  Set<Polyline> polylines = {};
  String? userEmail;
  StreamSubscription<QuerySnapshot>? reportsSubscription; // Listener para cambios en Firestore
  List<List<LatLng>> routes = [];
  int selectedRouteIndex = 0;
  VoidCallback? updateUI; // Callback para actualizar la UI

  //Clases de otros archivos, hace funcionar la aplicación *NO BORRAR*
  final RouteRepository routeRepository;
  final CalculateDistanceUseCase calculateDistanceUseCase = CalculateDistanceUseCase();
  final LocationService locationService = LocationService(); // Instancia de LocationService
  final UserService userService = UserService();
  final ReportsService reportsService = ReportsService();
  final MapUIService mapUIService = MapUIService(calculateDistanceUseCase: CalculateDistanceUseCase());

  MapController({required this.routeRepository});

  void init() {
    userService.getUserEmail().then((email) {
      userEmail = email;
    });
    _listenToReportChanges();
    // Iniciar la actualización de ubicación
    locationService.startLocationUpdates((LatLng position) {
      // Lógica adicional que se necesite al actualizar la posición
      updateUI?.call();
    });
  }

  void dispose() {
    locationService.stopLocationUpdates(); // Detener las actualizaciones de ubicación
    reportsSubscription?.cancel();
  }

  LatLng? get currentPosition => locationService.currentPosition; // Acceso a la posición actual

  Future<void> _getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    userEmail = user?.email;
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

    // Reinicia la suscripción a los reportes en tiempo real
    _listenToReportChanges();

    // Llamar al callback para actualizar la UI
    updateUI?.call();
  }

  Future<void> createReport(String reportType, String note) async {
    if (currentPosition == null) return;
    await reportsService.createReport(userEmail!, currentPosition!, reportType, note);
    _updateMarkersAndCircles(await reportsService.firestore.collection('reports').get());
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
    mapUIService.updateMarkersAndCircles(
      querySnapshot,
      markers,
      circles,
      routes,
      selectedRouteIndex,
      updateUI!,
    );
  }

// Función para verificar si un punto está cerca de la ruta seleccionada
  bool _isNearRoute(LatLng reportPosition, List<LatLng> route) {
    const double proximityThreshold = 50.0;
    for (var point in route) {
      if (calculateDistanceUseCase.execute(reportPosition, point) <= proximityThreshold) {
        return true;
      }
    }
    return false;
  }

  void _listenToReportChanges() {
    reportsSubscription?.cancel();
    reportsSubscription = reportsService.listenToReportChanges().listen((snapshot) {
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

    for (var point in route) {
      for (var marker in markers) {
        if (calculateDistanceUseCase.execute(point, marker.position) <= proximityThreshold) {
          reportCount++;
        }
      }
    }
    return reportCount;
  }

  Future<void> logout(BuildContext context) async {
    try {
      await userService.logout(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión')),
      );
    }
  }
}
