import 'package:moonhike/imports.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late RouteService routeService;
  late RouteRepository routeRepository;
  late MapController mapController;
  //late NewsService newsService;
  String? locationName; // Variable para almacenar el nombre de la ubicación
  bool showStartRouteButton = false;
  bool showSelectRouteButtons = false;
  bool isInfoTabOpen = false;
  LatLng? selectedLocation;
  String? duration; // Para almacenar la duración estimada
  String? distance; // Para almacenar la distancia estimada
  bool showRouteDetails = false;
//
  // Variables adicionales para almacenar routeInfos y routeRiskScores
  List<Map<String, dynamic>?> routeInfos = [];
  List<double> routeRiskScores = [];

  // Controlador para DraggableScrollableSheet
  final DraggableScrollableController _draggableController = DraggableScrollableController();

  final GlobalKey<AddressSearchWidgetState> _addressSearchKey = GlobalKey();

  Future<void> _onLocationSelected(LatLng location, String name) async {
    setState(() {
      selectedLocation = location;
      locationName = name;
      isInfoTabOpen = true;
    });

    // Calcula la información de las rutas y los puntajes de riesgo
    await mapController.calculateRouteInfoAndRiskScore(location);

    // Actualiza las variables en el estado usando los getters
    setState(() {
      routeInfos = mapController.routeInfos;
      routeRiskScores = mapController.routeRiskScores;
    });
  }

  Future<void> _startRoute() async {
    await mapController.startRoutes(selectedLocation, context);

    setState(() {
      showRouteDetails = true;
      // Asignar routeInfos y routeRiskScores después de que se calculen en mapController
      showSelectRouteButtons = true; // Habilitar los botones de selección de rutas
      routeInfos = mapController.routeInfos.isNotEmpty ? mapController.routeInfos : [];
      routeRiskScores = mapController.routeRiskScores.isNotEmpty ? mapController.routeRiskScores : [];
    });
  }

  @override
  void initState() {
    super.initState();

    routeService = RouteService();
    routeRepository = RouteRepository(routeService);
    mapController = MapController(routeRepository: routeRepository);
    /*newsService = NewsService(
      reportService: ReportsService(),
      mediaStackApiKey: ApiKeys.mediaStackApiKey,
      geocodingApiKey: ApiKeys.googleMapsApiKey,
    );*/
    mapController.setUpdateUICallback(() {
      if (mounted) setState(() {});


    });

    // Iniciar peticiones periódicas de noticias
    const query = 'asalto OR robo OR homicidio OR crimen OR balacera';
    //newsService.startFetchingReportsPeriodically(query); *QUITAR COMENTARIO AL SUBIR*

    // Eliminar reportes expirados
    //_deleteExpiredReports(); *QUITAR COMENTARIO AL SUBIR*

    // Pasa `context` aquí al llamar a `init`
    mapController.init(context);
    _checkLocationPermission();

    mapController.locationService.startLocationUpdates((position) {
      setState(() {
        mapController.controller?.animateCamera(CameraUpdate.newLatLng(position));
      });
    });
  }

  Future<void> testAutomatedNewsReport() async {
    final ReportsService reportService = ReportsService();

    try {
      // Simulación de datos de noticia
      String simulatedTitle = 'Asalto a mano armada en Monterrey';
      DateTime simulatedPublishedAt = DateTime.now();

      final GeoPoint? location = GeoPoint(25.7406533, -100.2932617);

      if (location != null) {
        // Crear un reporte usando la ubicación extraída
        await reportService.createReportFromNews(
          type: 'Inseguridad',
          note: simulatedTitle,
          location: location,
          expiration: simulatedPublishedAt.add(Duration(days: 1)), // Expira en 1 día
        );

        print('Reporte automatizado simulado creado exitosamente.');
      } else {
        print('No se pudo determinar la ubicación de la noticia simulada.');
      }
    } catch (e) {
      print('Error al probar la generación de reportes automatizados: $e');
    }
  }

  Future<void> _deleteExpiredReports() async {
    final reportsService = ReportsService();
    final deleteExpiredReports = DeleteExpiredReports(reportsService: reportsService);

    // Ejecuta la eliminación de reportes expirados
    await deleteExpiredReports.execute();
  }

  void _handleInfoTabPosition() {
    setState(() {
      isInfoTabOpen = _draggableController.size > 0.1;
    });
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    _moveToUserLocation();
  }

  Future<void> _moveToUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        mapController.locationService.currentPosition = userLocation;
      });

      double zoomLevel = 19.0;
      mapController.controller?.animateCamera(CameraUpdate.newLatLngZoom(userLocation, zoomLevel));
    } catch (e) {
      print('Error al obtener la ubicación del usuario: $e');
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    _draggableController.removeListener(_handleInfoTabPosition);
    //newsService.stopFetchingReportsPeriodically();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(mapController: mapController),
          Positioned(
            top: 70,
            left: 10,
            right: 10,
            child: AddressSearchWidget(
              key: _addressSearchKey, // Asigna la clave aquí
              onLocationSelected: _onLocationSelected, // Pasa ambos valores
            ),
          ),
          Positioned(
            bottom: isInfoTabOpen ? 270 : 150, // Ajusta según tu diseño
            left: 320,
            child: FindLocationButton(
              onPressed: () async {
                await _moveToUserLocation(); // Usa la función que ya definiste
              },
            ),
          ),
          Positioned(
            bottom: isInfoTabOpen ? 170 : 50,
            left: 320,
            child: FloatingActionButtons(
              onStartRoute: () async {
                try {
                  await mapController.startRoutes(selectedLocation, context);
                  setState(() { showRouteDetails = true; });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al iniciar la ruta: $e')),
                  );
                }
              },
              onCreateReport: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ReportDialog(
                      onReportTypeSelected: (String reportType, String note) async {
                        Navigator.of(context).pop();
                        try {
                          await mapController.createReport(reportType, note, context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error al crear reporte: $e'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,

                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
              showStartRouteButton: showStartRouteButton,
            ),
          ),
          if (isInfoTabOpen)
            if (showSelectRouteButtons)
              Positioned(
            bottom: 150,
            right: 130,
            child: SelectRouteWidget(
              showPreviousRoute: () => mapController.showPreviousRoute(context),
              showNextRoute: () => mapController.showNextRoute(context),
            ),
          ),
          if (isInfoTabOpen)
            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.05,
              maxChildSize: 0.2,
              builder: (context, scrollController) {
                return RouteInfoTab(
                  locationName: locationName ?? 'Ubicación seleccionada',
                  onClose: () {
                    setState(() {
                      // Restablece las variables relacionadas con el estado del InfoTab
                      isInfoTabOpen = false;
                      locationName = null;
                      showRouteDetails = false;
                      showStartRouteButton = false;
                      showSelectRouteButtons = false;

                      // Limpia las rutas y marcadores visuales en el mapa
                      mapController.clearRouteAndMarkers();

                      // Limpia las rutas locales y cualquier dato relacionado
                      routeInfos.clear();
                      routeRiskScores.clear();
                    });

                    // Llama al método clearSearch de AddressSearchWidget
                    _addressSearchKey.currentState?.clearSearch();
                  },
                  onStartRoute: _startRoute,
                  scrollController: scrollController, // Pasar scrollController aquí
                  routeInfos: routeInfos,
                  showRouteDetails: showRouteDetails,
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0, // Índice actual para la pantalla de Configuración
        onTap: (index) {}, // No necesitas ninguna lógica extra aquí
      ),
    );
  }
}
