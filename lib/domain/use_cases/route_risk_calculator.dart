import 'package:moonhike/imports.dart';

class RouteRiskCalculator {
  final CalculateDistanceUseCase calculateDistanceUseCase = CalculateDistanceUseCase();

  void updateRouteColors({
    required int selectedRouteIndex,
    required List<List<LatLng>> routes,
    required List<double> routeRiskScores,
    required Set<Polyline> polylines,
    required VoidCallback updateUI,
    required Set<Marker> markers,
  }) {
    polylines.clear();

    for (int i = 0; i < routes.length; i++) {
      Color routeColor;

      if (i == selectedRouteIndex) {
        double riskScore = calculateRouteRisk(routes[i], markers);
        routeColor = getRouteColor(riskScore);
        routeRiskScores[i] = riskScore;
      } else {
        routeColor = Colors.grey; // Las rutas no seleccionadas se muestran en gris
      }

      polylines.add(Polyline(
        polylineId: PolylineId('route_$i'),
        points: routes[i],
        color: routeColor,
        width: i == selectedRouteIndex ? 10 : 6,
        patterns: [PatternItem.dot, PatternItem.gap(15)],
      ));
    }

    updateUI();
  }

  double calculateRouteRisk(List<LatLng> route, Set<Marker> markers) {
    const double proximityThreshold = 50.0;
    double riskScore = 0;

    for (LatLng point in route) {
      for (Marker marker in markers) {
        if (calculateDistanceUseCase.execute(point, marker.position) <= proximityThreshold) {
          if (marker.infoWindow.title == "Mala iluminación") {
            riskScore += 3;
          } else if (marker.infoWindow.title == "Inseguridad") {
            riskScore += 5;
          } else if (marker.infoWindow.title == "Poca vialidad peatonal") {
            riskScore += 4;
          }
        }
      }
    }
    return riskScore;
  }

  Color getRouteColor(double riskScore) {
    if (riskScore < 10) {
      return Colors.green;
    } else if (riskScore <= 20) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}