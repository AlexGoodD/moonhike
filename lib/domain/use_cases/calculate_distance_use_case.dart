import 'dart:math' as math;
import 'package:moonhike/imports.dart';

class CalculateDistanceUseCase {
  double execute(LatLng point1, LatLng point2) {
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
}