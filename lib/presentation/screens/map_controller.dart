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
  final MapUIService mapUIService = MapUIService(calculateDistanceUseCase: CalculateDistanceUseCase());
  final DirectionsService directionsService = DirectionsService();
  final RouteRiskCalculator routeRiskCalculator = RouteRiskCalculator();

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
    await MapUtils.setMapController(mapControllerCompleter, controller);
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
      double riskScore = routeRiskCalculator.calculateRouteRisk(routes[i], markers);
      riskScores.add(riskScore);

      if (riskScore < lowestRiskScore) {
        lowestRiskScore = riskScore;
        safestRouteIndex = i;
      }

      Color routeColor = routeRiskCalculator.getRouteColor(riskScore);

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

  void _listenToReportChanges() {
    reportsSubscription?.cancel();
    reportsSubscription = reportsService.listenToReportChanges().listen((snapshot) async {
      _updateMarkersAndCircles(snapshot);
      await updateRouteColors(); // Asegura que los colores se actualicen en tiempo real
      updateUI?.call(); // Fuerza la actualización de la UI
    });
  }

  void addMarkerForSelectedLocation(LatLng location) {
    MapUtils.addMarkerForSelectedLocation(
      markers: markers,
      controller: controller!,
      location: location,
    );
  }

  /*
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
   */
}
