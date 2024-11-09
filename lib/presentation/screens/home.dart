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
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();

    // Inicializar los servicios y controlador
    routeService = RouteService();
    routeRepository = RouteRepository(routeService);
    mapController = MapController(routeRepository: routeRepository);

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
        return; // Permiso denegado, no continuar
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return; // Permiso denegado permanentemente, no continuar
    }
    // Permiso concedido, mueve la cámara a la ubicación del usuario
    _moveToUserLocation();
  }

  Future<void> _moveToUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        mapController.locationService.currentPosition = userLocation;
      });

      // Especifica el nivel de zoom al mover la cámara
      double zoomLevel = 23.0; // Puedes ajustar este valor según tus necesidades

      if (mapController.controller != null) {
        mapController.controller!.animateCamera(
          CameraUpdate.newLatLngZoom(userLocation, zoomLevel),
        );
      }
    } catch (e) {
      print('Error al obtener la ubicación del usuario: $e');
      // Opcionalmente, muestra un mensaje de error
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bienvenido', style: TextStyle(color: Colors.white, fontSize: 24)),
                  SizedBox(height: 10),
                  if (mapController.userEmail != null)
                    Text(mapController.userEmail!,
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar Sesión'),
              onTap: () async {
                await mapController.logout(context);
              },
            ),
          ],
        ),
      ),
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
                  setState(() {}); // Fuerza la actualización de la UI
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al iniciar la ruta: $e')));
                }
              },
              onCreateReport: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ReportDialog(
                      onReportTypeSelected: (String reportType, String note) async {
                        Navigator.of(context).pop(); // Cierra el diálogo
                        try {
                          await mapController.createReport(reportType, note); // Envía el tipo de reporte y la nota al controlador
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
        ],
      ),
    );
  }
}