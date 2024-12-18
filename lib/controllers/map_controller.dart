import 'package:moonhike/imports.dart';

class MapController {
  //List<int> routeTimes = []; //Tiempo de rutas
  List<double> _routeRiskScores = []; //Calificacion de rutas
  Completer<GoogleMapController> mapControllerCompleter = Completer(); // Eliminamos el "_"
  GoogleMapController? controller;
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  Set<Polyline> polylines = {};
  String? userEmail; //Email del usuario
  LatLng? lastDestination; //Ultima ruta (para evitar las presiones repetidas)
  StreamSubscription<QuerySnapshot>? reportsSubscription; // Listener para cambios en Firestore
  List<List<LatLng>> routes = [];
  int selectedRouteIndex = 0; //Selector de rutas
  VoidCallback? updateUI; // Callback para actualizar la UI
  List<Map<String, dynamic>?> routeInfos = [];
  Marker? selectedLocationMarker;
  String? distance; // Nueva variable para almacenar la distancia
  Timestamp? lastCheckedTimestamp;

  // Getter para routeInfos
  List<Map<String, dynamic>?> get _routeInfos => routeInfos;

  // Getter para routeRiskScores
  List<double> get routeRiskScores => _routeRiskScores;

  //Clases de otros archivos, hace funcionar la aplicación *NO BORRAR*
  final RouteRepository routeRepository;
  final CalculateDistanceUseCase calculateDistanceUseCase = CalculateDistanceUseCase();
  final LocationService locationService = LocationService(); // Instancia de LocationService
  final UserService userService = UserService();
  final ReportsService reportsService = ReportsService();
  final DirectionsService directionsService = DirectionsService();
  final RouteRiskCalculator routeRiskCalculator = RouteRiskCalculator();

  // Crea la instancia de MapUIService pasando `this` (MapController)
  final MapUIService mapUIService;


  MapController({required this.routeRepository})
      : mapUIService = MapUIService(
    calculateDistanceUseCase: CalculateDistanceUseCase(),
  );


  void init(BuildContext context) {
    userService.getUserEmail().then((email) {
      userEmail = email;
    });
    _listenToReportChanges(context);
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
    await MapUtils.setMapController(mapControllerCompleter, controller);
  }

  Future<void> loadReports(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference reports = firestore.collection('reports');
    QuerySnapshot querySnapshot = await reports.get();

    // Limpia los marcadores y círculos
    markers.clear();
    circles.clear();

    // Actualiza los marcadores y círculos basados en los reportes
    _updateMarkersAndCircles(querySnapshot, context, userEmail!);

    // Reagrega el marcador de la ubicación seleccionada si existe
    if (selectedLocationMarker != null) {
      markers.add(selectedLocationMarker!);
    }

    updateUI?.call();
  }

  Future<void> startRoutes(LatLng? destination, BuildContext context) async {
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
    await loadReports(context); // Carga los reportes una vez clasificadas las rutas
    updateUI?.call(); // Actualiza la UI después de clasificar y cargar los datos
  }

  Future<void> calculateRouteInfoAndRiskScore(LatLng destination) async {
    if (currentPosition == null) return;

    routes = await getRoutes(currentPosition!, destination);
    routeInfos.clear();
    _routeRiskScores.clear();

    for (var route in routes) {
      var info = await directionsService.getRouteInfo(currentPosition!, destination);

      // Llama a _countReportsInRoute para contar los reportes cercanos en esta ruta
      int reportCount = _countReportsInRoute(route);
      info?['reportCount'] = reportCount;
      routeInfos.add(info);

      // Calcula el riesgo de la ruta
      double riskScore = routeRiskCalculator.calculateRouteRisk(route, markers);
      _routeRiskScores.add(riskScore);
    }

    updateUI?.call();
  }

  //Migrar _classifyAndDisplayRoutes
  Future<void> _classifyAndDisplayRoutes() async {
    polylines.clear();
    List<double> riskScores = [];
    int safestRouteIndex = 0;
    double lowestRiskScore = double.infinity;

    for (int i = 0; i < routes.length; i++) {
      double riskScore = routeRiskCalculator.calculateRouteRisk(
          routes[i], markers);
      riskScores.add(riskScore);

      if (riskScore < lowestRiskScore) {
        lowestRiskScore = riskScore;
        safestRouteIndex = i;
      }

      Color routeColor = routeRiskCalculator.getRouteColor(riskScore);

      selectedRouteIndex = safestRouteIndex;
      updateUI?.call();
      polylines.add(Polyline(
        polylineId: PolylineId('route_$i'),
        points: routes[i],
        color: routeColor,
        width: 6,
        patterns: [PatternItem.dot, PatternItem.gap(15)],
      ));
    }
    _routeRiskScores = riskScores;
    selectedRouteIndex = safestRouteIndex;
    updateUI?.call();
  }



  Future<void> updateRouteColors() async {
    polylines.clear();
    routeRiskCalculator.updateRouteColors(
      selectedRouteIndex: selectedRouteIndex,
      routes: routes,
      routeRiskScores: _routeRiskScores,
      polylines: polylines,
      updateUI: updateUI!,
      markers: markers,
    );
  }

  /*Función calculateRouteRisk migrada a route_risk_calculator*/

  /*función getroutecolor migrada a route_risk_calculator*/

  Future<void> selectRoute(int index, BuildContext context) async {
    selectedRouteIndex = index;
    await updateRouteColors(); // Actualiza los colores para la ruta seleccionada
    await loadReports(context); // Carga y actualiza los reportes para la ruta seleccionada
    updateUI?.call(); // Actualiza la interfaz
  }


  // Métodos para navegar entre las rutas
  void showNextRoute(BuildContext context) {
    if (routes.isNotEmpty) {
      selectedRouteIndex = (selectedRouteIndex + 1) % routes.length;
      selectRoute(selectedRouteIndex, context);
    }
    updateUI?.call(); // Actualiza la UI después de clasificar
  }

  void showPreviousRoute(BuildContext context) {
    if (routes.isNotEmpty) {
      selectedRouteIndex = (selectedRouteIndex - 1 + routes.length) % routes.length;
      selectRoute(selectedRouteIndex, context);
    }
    updateUI?.call(); // Actualiza la UI después de clasificar
  }

  // Crea un reporte y actualiza marcadores/círculos en tiempo real
  Future<void> createReport(String reportType, String note, BuildContext context) async {
    if (currentPosition == null) return;
    await reportsService.createReport(userEmail!, currentPosition!, reportType, note);

    // Escucha nuevamente los cambios de Firebase para actualizar en tiempo real
    await loadReports(context);
    updateUI?.call(); // Actualiza la interfaz en tiempo real
  }

  Future<List<List<LatLng>>> getRoutes(LatLng start, LatLng end) async {
    // Usar RouteRepository para obtener las rutas
    return await routeRepository.fetchRoutes(start, end);
  }

  // Método para actualizar los marcadores en tiempo real basado en los reportes
  void _updateMarkersAndCircles(QuerySnapshot querySnapshot, BuildContext context, String userEmail) {
    mapUIService.updateMarkersAndCircles(
      snapshot: querySnapshot,
      markers: markers,
      circles: circles,
      routes: routes,
      selectedRouteIndex: selectedRouteIndex,
      updateUI: updateUI!,
      context: context,
      userEmail: userEmail!,
    );
    updateRouteColors();
    updateUI?.call();
  }

  Set<String> processedReportIds = {}; // IDs de reportes procesados

  void _listenToReportChanges(BuildContext context) {
    reportsSubscription?.cancel();
    reportsSubscription = reportsService.listenToReportChanges().listen((snapshot) async {

      // Limpia los marcadores antes de actualizar
      markers.clear();

      // Actualiza marcadores y círculos
      _updateMarkersAndCircles(snapshot, context, userEmail!);

      // Hora actual para comparar nuevos reportes
      final DateTime now = DateTime.now();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String reportId = doc.id; // Obtener el ID único del reporte

        // Verificar si este reporte ya fue procesado
        if (processedReportIds.contains(reportId)) {
          print("Reporte con ID $reportId ya procesado, ignorado.");
          continue; // Ignorar este reporte
        }

        // Verificar que el reporte tenga los datos necesarios
        if (data['location'] is GeoPoint && data['timestamp'] is Timestamp && data['user'] is String) {
          GeoPoint geoPoint = data['location'];
          LatLng reportLocation = LatLng(geoPoint.latitude, geoPoint.longitude);
          String reportUserEmail = data['user'];
          Timestamp reportTimestamp = data['timestamp'];

          DateTime reportTime = reportTimestamp.toDate();

          print("Comparando usuario actual (${userEmail?.trim()}) con el usuario del reporte (${reportUserEmail.trim()})");

          // **Ignorar reportes creados por el usuario actual**
          if (reportUserEmail.trim() == userEmail!.trim()) {
            print("Reporte creado por el usuario actual, ignorado.");
            continue;
          }

          // **Validar si el reporte fue creado en el mismo minuto**
          if (reportTime.year == now.year &&
              reportTime.month == now.month &&
              reportTime.day == now.day &&
              reportTime.hour == now.hour &&
              reportTime.minute == now.minute) {
            // Verificar proximidad del reporte
            if (_isReportNearUser(reportLocation)) {
              _showNotification(
                context,
                "Un reporte ha sido generado en tu área, toma tus precauciones.",
              );
            }
          }

          // Agregar el reporte procesado a la lista
          processedReportIds.add(reportId);
        } else {
          print("Reporte inválido: $data");
        }
      }

      _classifyAndDisplayRoutes();
      updateUI?.call(); // Fuerza la actualización de la UI después de cada cambio
    });
  }

  void clearRouteAndMarkers() {
    // Limpia todas las polilíneas, marcadores y círculos
    polylines.clear();
    markers.clear();
    circles.clear();

    // Restablece las rutas y los índices
    routes.clear();
    selectedRouteIndex = 0;

    // Actualiza la interfaz para reflejar los cambios
    updateUI?.call();
  }

  int _countReportsInRoute(List<LatLng> route) {
    int reportCount = 0;
    for (var marker in markers) {
      if (mapUIService.isNearRoute(marker.position, route)) {
        reportCount++;
      }
    }
    print('Total de reportes para esta ruta: $reportCount'); // Depuración
    return reportCount;
  }

  void addMarkerForSelectedLocation(LatLng location) {
    selectedLocationMarker = Marker(
      markerId: MarkerId('selectedLocation'),
      position: location,
      infoWindow: InfoWindow(title: 'Ubicación seleccionada'),
    );

    markers.add(selectedLocationMarker!);
    updateUI?.call();
  }

  // Método para calcular la distancia y almacenar el resultado
  Future<void> calculateDistanceTo(LatLng destination) async {
    if (currentPosition != null) {
      double calculatedDistance = calculateDistanceUseCase.execute(currentPosition!, destination);
      distance = '${(calculatedDistance / 1000).toStringAsFixed(2)} km'; // Convertir a km y formatear
      updateUI?.call();
    }
  }

// Función para seleccionar la ubicación y cargar la distancia
  Future<void> selectLocation(LatLng location) async {
    lastDestination = location;
    await calculateDistanceTo(location);
  }

  bool _isReportNearUser(LatLng reportLocation) {
    if (currentPosition == null) return false;

    const double distanceThreshold = 500; // Distancia en metros
    double distance = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      reportLocation.latitude,
      reportLocation.longitude,
    );

    return distance <= distanceThreshold;
  }

  void _showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
