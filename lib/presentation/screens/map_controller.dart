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

    // Filtra los reportes de acuerdo a la ruta seleccionada antes de actualizar los marcadores y círculos
    markers.clear();
    circles.clear();
    _updateMarkersAndCircles(querySnapshot, context, userEmail!);
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
      showDeleteDialog: showDeleteConfirmationDialog, // Pasamos la función de eliminación
    );
    // Forzar la actualización de colores inmediatamente después de recibir cambios
    updateRouteColors(); // Aplica el cambio de colores en tiempo real
    updateUI?.call(); // Fuerza la actualización de la UI
  }

  // Método de confirmación de eliminación
  void showDeleteConfirmationDialog(BuildContext parentContext, String reportId) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: paletteColors.secondColor, // Color de fondo del diálogo
          title: Text(
            "Eliminar reporte",
            style: TextStyle(
              color: Colors.white, // Color del texto del título
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "¿Estás seguro de que deseas eliminar este reporte?",
            style: TextStyle(
              color: paletteColors.fourthColor, // Color del texto del contenido
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancelar",
                style: TextStyle(color: paletteColors.cancelColor,               fontWeight: FontWeight.normal,
                ), // Color del botón "Cancelar"
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await reportsService.deleteReport(reportId);
                markers.removeWhere((marker) => marker.markerId.value == 'report_$reportId');
                circles.removeWhere((circle) => circle.circleId.value == 'danger_area_$reportId');
                updateUI?.call();
              },
              child: Text(
                "Eliminar",
                style: TextStyle(color: paletteColors.deleteColor,               fontWeight: FontWeight.bold,
                ), // Color del botón "Eliminar"
              ),
            ),
          ],
        );
      },
    );
  }

  void _listenToReportChanges(BuildContext context) {
    reportsSubscription?.cancel();
    reportsSubscription = reportsService.listenToReportChanges().listen((snapshot) async {
      _updateMarkersAndCircles(snapshot, context, userEmail!);
      _classifyAndDisplayRoutes();
      //await updateRouteColors(); // Asegura que los colores se actualicen en tiempo real
      //await loadReports(context); // Carga todos los reportes de nuevo
      updateUI?.call(); // Fuerza la actualización de la UI después de cada cambio
    });
  }

  void addMarkerForSelectedLocation(LatLng location) {
    MapUtils.addMarkerForSelectedLocation(
      markers: markers,
      controller: controller!,
      location: location,
    );
  }
}
