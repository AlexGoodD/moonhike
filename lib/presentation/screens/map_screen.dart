import 'package:geocoding/geocoding.dart';
import 'package:moonhike/imports.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late RouteService routeService;
  late RouteRepository routeRepository;
  late MapController mapController;
  String? locationName; // Variable para almacenar el nombre de la ubicación
  bool showStartRouteButton = false;
  bool isInfoTabOpen = false;
  LatLng? selectedLocation;
  String? duration; // Para almacenar la duración estimada
  String? distance; // Para almacenar la distancia estimada
  bool showRouteDetails = false;

  // Variables adicionales para almacenar routeInfos y routeRiskScores
  List<Map<String, dynamic>?> routeInfos = [];
  List<double> routeRiskScores = [];

  // Controlador para DraggableScrollableSheet
  final DraggableScrollableController _draggableController = DraggableScrollableController();

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

    mapController.setUpdateUICallback(() {
      setState(() {});
    });

    // Pasa `context` aquí al llamar a `init`
    mapController.init(context);
    _checkLocationPermission();

    mapController.locationService.startLocationUpdates((position) {
      setState(() {
        mapController.controller?.animateCamera(CameraUpdate.newLatLng(position));
      });
    });

    //_draggableController.addListener(_handleInfoTabPosition);
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
                onLocationSelected: _onLocationSelected, // Pasa ambos valores
            ),
          ),
          Positioned(
            bottom: isInfoTabOpen ? 150 : 25,
            right: 60,
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
                            SnackBar(content: Text('Error al crear reporte: $e')),
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
              minChildSize: 0.1,
              maxChildSize: 0.2,
              builder: (context, scrollController) {
                return RouteInfoTab(
                  locationName: locationName ?? 'Ubicación seleccionada',
                  onClose: () {
                    setState(() {
                      isInfoTabOpen = false;
                      locationName = null;
                      showRouteDetails = false;
                    });
                  },
                  onStartRoute: _startRoute,
                  scrollController: scrollController, // Pasar scrollController aquí
                  routeInfos: routeInfos,
                  routeRiskScores: routeRiskScores,
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