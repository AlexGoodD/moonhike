//Este archivo es el repositorio que interactúa con RouteService para obtener los datos de las rutas. Implementa la capa de acceso a datos.

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/route_service.dart';

class RouteRepository {
  final RouteService routeService;

  RouteRepository(this.routeService);

  Future<List<List<LatLng>>> fetchRoutes(LatLng start, LatLng end) {
    return routeService.getRoutes(start, end);

  }
}