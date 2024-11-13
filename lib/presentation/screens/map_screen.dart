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
  bool isInfoTabOpen = false;
  LatLng? selectedLocation;

  int _selectedIndex = 0;

  // Controlador para DraggableScrollableSheet
  final DraggableScrollableController _draggableController = DraggableScrollableController();

  final List<Widget> _pages = [
    MapScreen(), // Página de inicio/mapa
    ReportsScreen(), // Página de reportes
    SettingsScreen(), // Página de configuración
    ProfileScreen(), // Página de perfil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navegación a la página correspondiente
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReportsScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
    }
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

    mapController.init();
    _checkLocationPermission();

    mapController.locationService.startLocationUpdates((position) {
      setState(() {
        mapController.controller?.animateCamera(CameraUpdate.newLatLng(position));
      });
    });

    _draggableController.addListener(_handleInfoTabPosition);
  }

  void _handleInfoTabPosition() {
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
    _draggableController.removeListener(_handleInfoTabPosition);
    super.dispose();
  }

  /*
  void _checkAuthentication() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // Si no hay usuario autenticado, redirige a la pantalla de login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }*/

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
            bottom: isInfoTabOpen ? 250 : 120,
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
            bottom: isInfoTabOpen ? 160 : 50,
            right: 130,
            child: SelectRouteWidget(
              showPreviousRoute: mapController.showPreviousRoute,
              showNextRoute: mapController.showNextRoute,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}