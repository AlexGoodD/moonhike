import 'package:moonhike/imports.dart';

class MapController {
  List<int> routeTimes = []; // Almacena tiempos estimados en minutos
  List<double> _routeRiskScores = [];
  Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? controller;
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  Set<Polyline> polylines = {};
  String? userEmail;
  LatLng? lastDestination; // Último destino mostrado
  StreamSubscription<QuerySnapshot>? reportsSubscription; // Listener para cambios en Firestore
  List<List<LatLng>> routes = [];
  int selectedRouteIndex = 0;
  VoidCallback? updateUI; // Callback para actualizar la UI
  List<Map<String, dynamic>?> routeInfos = [];

  //Clases de otros archivos, hace funcionar la aplicación *NO BORRAR*
  final RouteRepository routeRepository;
  final CalculateDistanceUseCase calculateDistanceUseCase = CalculateDistanceUseCase();
  final LocationService locationService = LocationService(); // Instancia de LocationService
  final UserService userService = UserService();
  final ReportsService reportsService = ReportsService();
  final MapUIService mapUIService = MapUIService(calculateDistanceUseCase: CalculateDistanceUseCase());
  final DirectionsService directionsService = DirectionsService();

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

    // Clasifica y selecciona la ruta más segura
    _classifyAndDisplayRoutes();
  }

  void dispose() {
    locationService.stopLocationUpdates(); // Detener las actualizaciones de ubicación
    reportsSubscription?.cancel();
  }

  LatLng? get currentPosition => locationService.currentPosition; // Acceso a la posición actual


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

  Future<void> loadReports() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference reports = firestore.collection('reports');
    QuerySnapshot querySnapshot = await reports.get();

    // Filtra los reportes de acuerdo a la ruta seleccionada antes de actualizar los marcadores y círculos
    _updateMarkersAndCircles(querySnapshot);
    updateUI?.call(); // Asegura que la UI se actualice con los reportes cargados
  }

  Future<void> startRoutes(LatLng? destination) async {
    if (currentPosition == null || destination == null) return;
    if (lastDestination != null && lastDestination == destination) {
      print("Destino sin cambios; no se cargan nuevas rutas.");
      return;
    }

    lastDestination = destination;
    routes = await getRoutes(currentPosition!, destination);
    routeInfos.clear();

    for (var route in routes) {
      var info = await directionsService.getRouteInfo(currentPosition!, destination);
      routeInfos.add(info);
    }

    await _classifyAndDisplayRoutes(); // Clasifica y selecciona las rutas antes de cargar reportes
    await loadReports(); // Carga los reportes una vez clasificadas las rutas
    updateUI?.call(); // Actualiza la UI después de clasificar y cargar los datos
  }

  Future<void> _classifyAndDisplayRoutes() async {
    polylines.clear();
    List<double> riskScores = [];
    int safestRouteIndex = 0;
    double lowestRiskScore = double.infinity;

    for (int i = 0; i < routes.length; i++) {
      double riskScore = _calculateRouteRisk(routes[i]);
      riskScores.add(riskScore);

      if (riskScore < lowestRiskScore) {
        lowestRiskScore = riskScore;
        safestRouteIndex = i;
      }

      Color routeColor = _getRouteColor(riskScore);

      polylines.add(Polyline(
        polylineId: PolylineId('route_$i'),
        points: routes[i],
        color: routeColor,
        width: 6,
        patterns: [PatternItem.dot, PatternItem.gap(15)],
      ));
    }
    _routeRiskScores = riskScores;
    selectedRouteIndex = safestRouteIndex; // Selecciona la ruta más segura para mostrar primero
    updateUI?.call(); // Actualiza la UI después de clasificar
  }

  double _calculateRouteRisk(List<LatLng> route) {
    const double proximityThreshold = 50.0; // Distancia en metros para considerar un reporte cercano
    double riskScore = 0;

    for (LatLng point in route) {
      for (Marker marker in markers) {
        if (calculateDistanceUseCase.execute(point, marker.position) <= proximityThreshold) {
          // Suma puntos de riesgo según el tipo de reporte
          if (marker.infoWindow.title == "Mala iluminación") {
            riskScore += 3;
          } else if (marker.infoWindow.title == "Inseguridad") {
            riskScore += 5;
          } else if (marker.infoWindow.title == "Poca vialidad peatonal") {
            riskScore += 4;
          }
        }
      }
    }
    return riskScore;
  }

  Color _getRouteColor(double riskScore) {
    if (riskScore < 10) {
      return Colors.green; // Ruta segura
    } else if (riskScore <= 20) {
      return Colors.yellow; // Ruta intermedia
    } else {
      return Colors.red; // Ruta insegura
    }
  }

  Future<void> selectRoute(int index) async {
    selectedRouteIndex = index;
    await updateRouteColors(); // Actualiza los colores para la ruta seleccionada
    await loadReports(); // Carga y actualiza los reportes para la ruta seleccionada
    updateUI?.call(); // Actualiza la interfaz
  }


  // Métodos para navegar entre las rutas
  void showNextRoute() {
    if (routes.isNotEmpty) {
      selectedRouteIndex = (selectedRouteIndex + 1) % routes.length;
      selectRoute(selectedRouteIndex);
    }
    updateUI?.call(); // Actualiza la UI después de clasificar
  }

  void showPreviousRoute() {
    if (routes.isNotEmpty) {
      selectedRouteIndex = (selectedRouteIndex - 1 + routes.length) % routes.length;
      selectRoute(selectedRouteIndex);
    }
    updateUI?.call(); // Actualiza la UI después de clasificar
  }

  // Crea un reporte y actualiza marcadores/círculos en tiempo real
  Future<void> createReport(String reportType, String note) async {
    if (currentPosition == null) return;
    await reportsService.createReport(userEmail!, currentPosition!, reportType, note);

    // Escucha nuevamente los cambios de Firebase para actualizar en tiempo real
    await loadReports();
    updateUI?.call(); // Actualiza la interfaz en tiempo real
  }

  Future<List<List<LatLng>>> getRoutes(LatLng start, LatLng end) async {
    // Usar RouteRepository para obtener las rutas
    return await routeRepository.fetchRoutes(start, end);
  }

  // Método para actualizar los marcadores en tiempo real basado en los reportes
  void _updateMarkersAndCircles(QuerySnapshot querySnapshot) {
    mapUIService.updateMarkersAndCircles(
      querySnapshot,
      markers,
      circles,
      routes,
      selectedRouteIndex, // Aplica solo a la ruta seleccionada
      updateUI!,
    );

    // Forzar la actualización de colores inmediatamente después de recibir cambios
    updateRouteColors(); // Aplica el cambio de colores en tiempo real
    updateUI?.call(); // Fuerza la actualización de la UI
  }

  Future<void> updateRouteColors() async {
    // Limpia los polylines actuales para una actualización completa
    polylines.clear();

    for (int i = 0; i < routes.length; i++) {
      Color routeColor;

      // Recalcula el color basado en el riesgo solo para la ruta seleccionada
      if (i == selectedRouteIndex) {
        double riskScore = _calculateRouteRisk(routes[i]);
        routeColor = _getRouteColor(riskScore);
        _routeRiskScores[i] = riskScore; // Asegura que el puntaje de riesgo esté actualizado
      } else {
        // Rutas no seleccionadas se muestran en gris
        routeColor = Colors.grey;
      }

      // Añade el polyline de la ruta con el color correspondiente
      polylines.add(Polyline(
        polylineId: PolylineId('route_$i'),
        points: routes[i],
        color: routeColor,
        width: i == selectedRouteIndex ? 10 : 6,
        patterns: [PatternItem.dot, PatternItem.gap(15)],
      ));
    }

    updateUI?.call(); // Refresca la UI después de la actualización de colores
  }

  void _listenToReportChanges() {
    reportsSubscription?.cancel();
    reportsSubscription = reportsService.listenToReportChanges().listen((snapshot) async {
      _updateMarkersAndCircles(snapshot);
      await updateRouteColors(); // Asegura que los colores se actualicen en tiempo real
      updateUI?.call(); // Fuerza la actualización de la UI
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
