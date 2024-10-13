import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moonhike/data/models/route_service.dart';
import 'package:moonhike/data/repositories/route_repository.dart';
import 'package:moonhike/domain/use_cases/calculate_distance_use_case.dart';
import 'package:moonhike/domain/use_cases/get_routes_use_case.dart';
import 'package:moonhike/core/widgets/address_search_widget.dart';
import '../../core/utils/location_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:async';
import 'login.dart';
import 'profile_screen.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}
//Commit prueba
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

  final RouteRepository routeRepository = RouteRepository(
      RouteService('AIzaSyDNHOPdlWDOqsFiL9_UQCkg2fnlpyww6A4'));
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
      _userEmail = user?.email; // Guarda el correo en la variable
    });
  }

  // Inicia la escucha de actualizaciones de ubicación
  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        // Alta precisión para detectar movimientos pequeños
        distanceFilter: 10, // Actualizar cuando el usuario se mueva al menos 10 metros
      ),
    ).listen((Position position) {
      // Actualiza la posición actual y refresca el mapa
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        //_updateCurrentLocationMarker();
      });

      // Mueve la cámara a la nueva posición del usuario
      if (_controller != null) {
        _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
      }
    });
  }

  // Función para cerrar sesión
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut(); // Cierra sesión en Firebase

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userUID');

    Navigator.pushReplacement( // Redirige al LoginPage
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Radio de la Tierra en metros
    double dLat = (point2.latitude - point1.latitude) * (math.pi / 180);
    double dLon = (point2.longitude - point1.longitude) * (math.pi / 180);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(point1.latitude * (math.pi / 180)) *
            math.cos(point2.latitude * (math.pi / 180)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> _loadReports() async {
    if (_currentPosition == null) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference reports = firestore.collection('reports');

    // Traer todos los reportes desde Firestore
    QuerySnapshot querySnapshot = await reports.get();

    const double proximityThreshold = 50.0; // Umbral de proximidad en metros

    setState(() {
      _markers.clear();
      _circles.clear();

      // Filtrar los reportes según la proximidad a la ruta o a la posición actual
      for (var doc in querySnapshot.docs) {
        GeoPoint location = doc['location'];
        LatLng reportPosition = LatLng(location.latitude, location.longitude);

        bool isNearCurrentPosition =
            calculateDistance(_currentPosition!, reportPosition) <=
                proximityThreshold;

        bool isNearRoute = _routes[_selectedRouteIndex].any((
            LatLng routePoint) {
          double distance = calculateDistance(reportPosition, routePoint);
          return distance <= proximityThreshold;
        });

        if (isNearCurrentPosition || isNearRoute) {
          // Agregar marcador del reporte
          _markers.add(Marker(
            markerId: MarkerId('report_${doc.id}'),
            position: reportPosition,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: 'Reporte de ${doc['user']}',
              snippet: 'Generado el ${doc['timestamp'].toDate()}',
            ),
          ));

          // Dibujar círculo para el área de peligro
          _circles.add(Circle(
            circleId: CircleId('danger_area_${doc.id}'),
            center: reportPosition,
            radius: 20,
            // Radio del área en metros
            fillColor: Colors.red.withOpacity(0.3),
            strokeColor: Colors.red,
            strokeWidth: 2,
          ));
        }
      }
    });
  }

  /*
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
*/
  Set<Circle> _circles = {};

  Future<void> _createReport() async {
    try {
      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo obtener la ubicación actual')),
        );
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference reports = firestore.collection('reports');

      // Crear el reporte en Firestore
      await reports.add({
        'user': _userEmail,
        'location': GeoPoint(
            _currentPosition!.latitude, _currentPosition!.longitude),
        'routeIndex': _selectedRouteIndex,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        // Crear un marcador para el reporte
        final newMarker = Marker(
          markerId: MarkerId('new_report_${DateTime
              .now()
              .millisecondsSinceEpoch}'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Tu Reporte',
            snippet: 'Generado en tu ubicación actual',
          ),
        );
        _markers.add(newMarker);

        // Crear un círculo para el área de peligro
        final dangerArea = Circle(
          circleId: CircleId('danger_area_${DateTime
              .now()
              .millisecondsSinceEpoch}'),
          center: _currentPosition!,
          radius: 10,
          // Radio en metros
          fillColor: Colors.red.withOpacity(0.5),
          strokeColor: Colors.red,
          strokeWidth: 2,
        );
        _circles.add(dangerArea);
      });

      // Mover la cámara a la nueva ubicación del marcador
      if (_controller != null) {
        _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 16),
        );
      }

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

  // Inicia la búsqueda de rutas
  Future<void> _startRoutes() async {
    if (_currentPosition == null || _selectedLocation == null) return;

    _routes =
    await getRoutesUseCase.execute(_currentPosition!, _selectedLocation!);

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
    _loadReports();
  }

  // Selecciona una ruta de las disponibles
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
    _loadReports(); // Cargar reportes para la ruta seleccionada
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bienvenido',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                  SizedBox(height: 10),
                  if (_userEmail != null)
                    Text(_userEmail!,
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
              onTap: _logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(title: Text('MoonHike')),
      body: Stack(
        children: [
          // Mapa de Google
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? LatLng(25.6866, -100.3161),
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              if (_currentPosition != null) {
                _controller?.animateCamera(
                    CameraUpdate.newLatLng(_currentPosition!));
              }
            },
            markers: _markers,
            circles: _circles,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // Barra de búsqueda de direcciones
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: AddressSearchWidget(
              onLocationSelected: (LatLng location) {
                setState(() {
                  _selectedLocation = location;
                  _markers.add(Marker(
                    markerId: MarkerId('selectedLocation'),
                    position: _selectedLocation!,
                    infoWindow: InfoWindow(title: 'Ubicación seleccionada'),
                  ));

                  _controller?.animateCamera(
                      CameraUpdate.newLatLng(_selectedLocation!));

                  _showStartRouteButton = true;
                });
              },
            ),
          ),

          // Botones redondos para iniciar ruta y generar reporte
          Positioned(
            bottom: 150,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showStartRouteButton)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: FloatingActionButton(
                      onPressed: _startRoutes,
                      child: Icon(Icons.directions_walk),
                      backgroundColor: Colors.blue,
                      heroTag: 'startRouteButton',
                    ),
                  ),
                FloatingActionButton(
                  onPressed: _createReport,
                  child: Icon(Icons.report),
                  backgroundColor: Colors.red,
                  heroTag: 'createReportButton',
                ),
              ],
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
                      backgroundColor:
                      index == _selectedRouteIndex ? Colors.blue : Colors.grey,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}