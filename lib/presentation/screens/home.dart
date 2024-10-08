import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:moonhike/core/widgets/address_search_widget.dart';
import 'package:moonhike/data/models/route_service.dart';
import 'package:moonhike/data/repositories/route_repository.dart';
import 'package:moonhike/domain/use_cases/get_routes_use_case.dart';

import '../../core/utils/location_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moonhike/presentation/screens/login.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  bool _showStartRouteButton = false;
  Set<Polyline> _polylines = {};
  int _selectedRouteIndex = 0;
  List<List<LatLng>> _routes = [];
  String? _userEmail;
  StreamSubscription<Position>? _positionStream;

  final RouteRepository routeRepository = RouteRepository(RouteService('AIzaSyDNHOPdlWDOqsFiL9_UQCkg2fnlpyww6A4'));
  late GetRoutesUseCase getRoutesUseCase;

  _MapScreenState() {
    getRoutesUseCase = GetRoutesUseCase(routeRepository);
  }

  @override
  void initState() {
    super.initState();
    _getUserEmail(); // Obtén el correo electrónico del usuario
    _startLocationUpdates(); // Inicia la escucha de las actualizaciones de ubicación
  }

  @override
  void dispose() {
    // Cancela el stream de ubicación al salir de la pantalla
    _positionStream?.cancel();
    super.dispose();
  }

  // Método para obtener el correo del usuario
  void _getUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email;  // Guarda el correo en la variable
    });
  }

  // Establece la ubicación inicial
  void _setInitialLocation() async {
    try {
      Position position = await LocationUtils.getUserLocation();
      print("Ubicación actual: ${position.latitude}, ${position.longitude}");

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _markers.add(Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: 'Mi Ubicación'),
        ));
      });

      _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    } catch (e) {
      print('Error obteniendo la ubicación: $e');
      setState(() {
        _currentPosition = LatLng(25.6866, -100.3161);  // Monterrey por defecto
        _markers.add(Marker(
          markerId: MarkerId('defaultLocation'),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: 'Ubicación por Defecto: Monterrey'),
        ));
      });

      _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  // Función para cerrar sesión
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();  // Cierra sesión en Firebase
    Navigator.pushReplacement( // Redirige al LoginPage
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Función para cargar los reportes
  Future<void> _loadReports() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference reports = firestore.collection('reports');

    QuerySnapshot querySnapshot = await reports
        .where('routeIndex', isEqualTo: _selectedRouteIndex)
        .get();

    const double proximityThreshold = 100.0; // Umbral de proximidad en metros

    setState(() {
      _markers.addAll(querySnapshot.docs.map((doc) {
        GeoPoint location = doc['location'];
        LatLng reportPosition = LatLng(location.latitude, location.longitude);

        bool isNearRoute = _routes[_selectedRouteIndex].any((LatLng routePoint) {
          double distance = _calculateDistance(reportPosition, routePoint);
          return distance <= proximityThreshold;
        });

        if (isNearRoute) {
          return Marker(
            markerId: MarkerId('report_${doc.id}'),
            position: reportPosition,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: 'Reporte de ${doc['user']}',
              snippet: 'Generado el ${doc['timestamp'].toDate()}',
            ),
          );
        }

        return null;
      }).whereType<Marker>().toList());
    });
  }

  // Función para crear un reporte
  Future<void> _createReport() async {
    try {
      if (_currentPosition == null) throw 'La ubicación actual no está disponible.';

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference reports = firestore.collection('reports');

      // Crear el reporte en Firestore
      await reports.add({
        'user': _userEmail,
        'location': GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        'routeIndex': _selectedRouteIndex,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        final newMarker = Marker(
          markerId: MarkerId('new_report_${DateTime.now().millisecondsSinceEpoch}'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Tu Reporte',
            snippet: 'Generado en tu ubicación actual',
          ),
        );
        _markers.add(newMarker);

        // Mover la cámara a la nueva ubicación del marcador
        _controller?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 16));

        print("Marcador de reporte añadido en: $_currentPosition");
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reporte creado exitosamente')),
      );
    } catch (e) {
      print('Error al generar el reporte: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar el reporte: $e')),
      );
    }
  }

  // Inicia las rutas
  Future<void> _startRoutes() async {
    await _updateCurrentLocation(); // Actualiza la ubicación antes de iniciar las rutas
    if (_currentPosition == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una ubicación')),
      );
      return;
    }

    try {
      _routes = await getRoutesUseCase.execute(_currentPosition!, _selectedLocation!);

      setState(() {
        _polylines.clear();
        for (int i = 0; i < _routes.length; i++) {
          _polylines.add(Polyline(
            polylineId: PolylineId('route_$i'),
            points: _routes[i],
            color: i == _selectedRouteIndex ? Colors.blue : Colors.grey,
            width: 5,
          ));
        }
      });
    } catch (e) {
      print('Error obteniendo las rutas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener las rutas')),
      );
    }
  }

  // Selecciona una ruta
  void _selectRoute(int index) {
    setState(() {
      _selectedRouteIndex = index;
      _polylines.clear();
      for (int i = 0; i < _routes.length; i++) {
        _polylines.add(Polyline(
          polylineId: PolylineId('route_$i'),
          points: _routes[i],
          color: i == _selectedRouteIndex ? Colors.blue : Colors.grey,
          width: 5,
        ));
      }
    });
    _loadReports();  // Cargar reportes para la ruta seleccionada
  }

  // Reportar un problema
  void _reportIssue(BuildContext context) async {
    await _updateCurrentLocation(); // Actualiza la ubicación antes de hacer el reporte
    User? currentUser = FirebaseAuth.instance.currentUser;
    String email = currentUser?.email ?? 'Usuario Desconocido';
    String? selectedIssue;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Qué desea reportar?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('No hay luz'),
                leading: Radio<String>(
                  value: 'No hay luz',
                  groupValue: selectedIssue,
                  onChanged: (value) {
                    setState(() {
                      selectedIssue = value;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('Zona conflictiva'),
                leading: Radio<String>(
                  value: 'Zona conflictiva',
                  groupValue: selectedIssue,
                  onChanged: (value) {
                    setState(() {
                      selectedIssue = value;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedIssue != null) {
      String currentTime = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
      _addMarker(_currentPosition!, 'issue_${_markers.length}', 'Reporte: $selectedIssue',
          snippet: 'Usuario: $email\nHora: $currentTime');
      _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar Sesión'),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: Text('MoonHike')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? LatLng(25.6866, -100.3161),
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              if (_currentPosition != null) {
                _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
              }
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: AddressSearchWidget(
              onLocationSelected: (LatLng location) {
                setState(() {
                  _selectedLocation = location;
                  _addMarker(_selectedLocation!, 'selectedLocation', 'Ubicación seleccionada');
                  _controller?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));

                  // Muestra el botón para iniciar rutas
                  _showStartRouteButton = true;
                });
              },
            ),
          ),
          if (_showStartRouteButton)
            Positioned(
              bottom: 100,
              left: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: _startRoutes,
                child: Text('Iniciar Rutas'),
              ),
            ),
          // Opciones de selección de rutas
          if (_routes.isNotEmpty)
            Positioned(
              bottom: 170,
              left: 10,
              right: 10,
              child: Column(
                children: List.generate(_routes.length, (index) {
                  return ElevatedButton(
                    onPressed: () => _selectRoute(index),
                    child: Text('Seleccionar Ruta ${index + 1}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: index == _selectedRouteIndex ? Colors.blue : Colors.grey,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _reportIssue(context),
        child: Icon(Icons.report),
        backgroundColor: Colors.red,
      ),
    );
  }
}