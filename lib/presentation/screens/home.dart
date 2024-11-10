import 'package:moonhike/imports.dart';
import '../widgets/route_info_tab.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late RouteService routeService;
  late RouteRepository routeRepository;
  late MapController mapController;

  bool showStartRouteButton = false;
  LatLng? selectedLocation;

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MapScreen(), // Página de inicio/mapa
    //ReportsScreen(), // Página de reportes
    //SettingsScreen(), // Página de configuración
    ProfileScreen(), // Página de perfil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    // Inicializar los servicios y controlador
    routeService = RouteService();
    routeRepository = RouteRepository(routeService);

    // Inicializar `MapController` con `routeManager`
    mapController = MapController(
      routeRepository: routeRepository,
    );

    // Establecer el callback para actualizar la UI
    mapController.setUpdateUICallback(() {
      setState(() {});
    });

    // Inicializar el controlador y verificar permisos de ubicación
    mapController.init();
    _checkLocationPermission();

    // Iniciar la escucha de actualizaciones de ubicación
    mapController.locationService.startLocationUpdates((position) {
      setState(() {
        mapController.controller?.animateCamera(CameraUpdate.newLatLng(position));
      });
    });
  }

  // Verifica y solicita permisos de ubicación, y mueve la cámara si es necesario
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
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

      if (mapController.controller != null) {
        mapController.controller!.animateCamera(
          CameraUpdate.newLatLngZoom(userLocation, zoomLevel),
        );
      }
    } catch (e) {
      print('Error al obtener la ubicación del usuario: $e');
    }
  }

  @override
  void dispose() {
    mapController.dispose();
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
            bottom: 150,
            right: 20,
            child: FloatingActionButtons(
              onStartRoute: () async {
                try {
                  await mapController.startRoutes(selectedLocation);
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al iniciar la ruta: $e')));
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
          if (mapController.routes.isNotEmpty)
            Positioned(
              bottom: 600,
              left: 20,
              right: 20,
              child: RouteInfoTab(
                duration: mapController.routeInfos[mapController.selectedRouteIndex]?['duration'],
                distance: mapController.routeInfos[mapController.selectedRouteIndex]?['distance'],
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