import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

double calculate_distance_use_case(LatLng start, LatLng end) {
  const double earthRadius = 6371000; // Radio de la Tierra en metros

  final lat1 = math.pi * start.latitude / 180;
  final lat2 = math.pi * end.latitude / 180;
  final lon1 = math.pi * start.longitude / 180;
  final lon2 = math.pi * end.longitude / 180;

  final dLat = lat2 - lat1;
  final dLon = lon2 - lon1;

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);

  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadius * c; // Resultado en metros
}