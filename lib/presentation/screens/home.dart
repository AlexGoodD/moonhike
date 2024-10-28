// home.dart
import 'package:flutter/material.dart';
import 'package:moonhike/imports.dart';
import 'package:moonhike/presentation/widgets/floating_action_buttons.dart';
import 'package:moonhike/presentation/screens/map_controller.dart';

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

    // Initialize the services and controller
    routeService = RouteService('YOUR_API_KEY');
    routeRepository = RouteRepository(routeService);
    mapController = MapController(routeRepository: routeRepository);

    // Set callback to update UI
    mapController.setUpdateUICallback(() {
      setState(() {});
    });

    // Start location updates
    mapController.init();
    mapController.startLocationUpdates((position) {
      setState(() {
        mapController.controller?.animateCamera(CameraUpdate.newLatLng(position));
      });
    });

    // Fetch current location manually if not set
    if (mapController.currentPosition == null) {
      Geolocator.getCurrentPosition().then((position) {
        setState(() {
          mapController.currentPosition = LatLng(position.latitude, position.longitude);
          mapController.controller?.animateCamera(CameraUpdate.newLatLng(mapController.currentPosition!));
        });
      });
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
              onCreateReport: (type, note) async {
                try {
                  await mapController.createReport(context, type, note);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear reporte: $e')));
                }
              },
              showStartRouteButton: showStartRouteButton,
            ),
          ),
        ],
      ),
    );
  }
}
