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

    // Crear un conjunto para almacenar los marcadores ya procesados en esta ruta
    Set<String> processedMarkers = {};

    for (LatLng point in route) {
      for (Marker marker in markers) {
        double distance = calculateDistanceUseCase.execute(point, marker.position);

        // Procesar solo los marcadores dentro del umbral y que no hayan sido contados
        if (distance <= proximityThreshold && !processedMarkers.contains(marker.markerId.value)) {
          String markerTitle = marker.infoWindow.title ?? '';
          processedMarkers.add(marker.markerId.value); // Marcar como procesado

          if (markerTitle == "Mala iluminación") {
            print("Sumando 3 puntos por 'Mala iluminación'");
            riskScore += 3;
          } else if (markerTitle == "Inseguridad") {
            print("Sumando 5 puntos por 'Inseguridad'");
            riskScore += 5;
          } else if (markerTitle == "Poca vialidad peatonal") {
            print("Sumando 4 puntos por 'Poca vialidad peatonal'");
            riskScore += 4;
          } else {
            print("Marcador desconocido: $markerTitle");
          }
        }
      }
    }

    print("Puntaje de riesgo total para la ruta: $riskScore");
    return riskScore;
  }

  //Mala iluminación 6, Inseguridad 20, Interes peatonal 0

  Color getRouteColor(double riskScore) {
    if (riskScore < 10) {
      print("Color asignado: Verde para puntaje de riesgo $riskScore");
      return Colors.green;
    } else if (riskScore <= 20) {
      print("Color asignado: Amarillo para puntaje de riesgo $riskScore");
      return Colors.yellow;
    } else {
      print("Color asignado: Rojo para puntaje de riesgo $riskScore");
      return Colors.red;
    }
  }
}