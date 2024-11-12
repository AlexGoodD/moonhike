import 'package:moonhike/imports.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late RouteService routeService;
  late RouteRepository routeRepository;
  late MapController mapController;

  bool showStartRouteButton = false;
  bool isInfoTabOpen = false; // Controla el estado de la pestaña de información
  LatLng? selectedLocation;

  // Controlador para DraggableScrollableSheet
  final DraggableScrollableController _draggableController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();

    routeService = RouteService();
    routeRepository = RouteRepository(routeService);
    mapController = MapController(routeRepository: routeRepository);

    mapController.setUpdateUICallback(() {
      setState(() {});
    });

    mapController.init();
    _checkLocationPermission();

    mapController.locationService.startLocationUpdates((position) {
      setState(() {
        mapController.controller?.animateCamera(CameraUpdate.newLatLng(position));
      });
    });

    // Añade el listener al DraggableScrollableController para monitorear el tamaño
    _draggableController.addListener(_handleInfoTabPosition);
  }

  void _handleInfoTabPosition() {
    // Cambia isInfoTabOpen dependiendo del tamaño actual del DraggableScrollableSheet
    if (_draggableController.size > 0.2 && !isInfoTabOpen) {
      setState(() {
        isInfoTabOpen = true;
      });
    } else if (_draggableController.size <= 0.1 && isInfoTabOpen) {
      setState(() {
        isInfoTabOpen = false;
      });
    }
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

      double zoomLevel = 15.0;
      mapController.controller?.animateCamera(CameraUpdate.newLatLngZoom(userLocation, zoomLevel));
    } catch (e) {
      print('Error al obtener la ubicación del usuario: $e');
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    _draggableController.removeListener(_handleInfoTabPosition); // Elimina el listener al destruir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MoonHike')),
      body: Stack(
        children: [
          MapWidget(mapController: mapController),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: AddressSearchWidget(
              onLocationSelected: (LatLng location) {
                setState(() {
                  selectedLocation = location;
                  mapController.addMarkerForSelectedLocation(location);
                  showStartRouteButton = true;
                });
              },
            ),
          ),
          Positioned(
            bottom: isInfoTabOpen ? 250 : 120, // Eleva los botones cuando infoTab está abierto
            left: 330,
            child: FloatingActionButtons(
              onStartRoute: () async {
                try {
                  await mapController.startRoutes(selectedLocation);
                  setState(() {});
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
                          await mapController.createReport(reportType, note);
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
          Positioned(
            bottom: isInfoTabOpen ? 160 : 50, // Eleva SelectRouteWidget cuando infoTab está abierto
            right: 130,
            child: SelectRouteWidget(
              showPreviousRoute: mapController.showPreviousRoute,
              showNextRoute: mapController.showNextRoute,
            ),
          ),

          /*Info tab información acerca de las rutas
          if (mapController.routes.isNotEmpty &&
              mapController.routeInfos.isNotEmpty &&
              mapController.selectedRouteIndex < mapController.routeInfos.length)
            DraggableScrollableSheet(
              controller: _draggableController, // Asigna el controlador
              initialChildSize: 0.2,
              minChildSize: 0.1,
              maxChildSize: 0.4,
              builder: (BuildContext context, ScrollController scrollController) {
                return RouteInfoTab(
                  duration: mapController.routeInfos[mapController.selectedRouteIndex]?['duration'],
                  distance: mapController.routeInfos[mapController.selectedRouteIndex]?['distance'],
                  scrollController: scrollController,
                  onClose: () => _draggableController.jumpTo(0.1), // Cierra al tamaño mínimo
                );
              },
            ),*/
        ],
      ),
    );
  }
}