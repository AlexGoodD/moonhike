import 'package:moonhike/imports.dart';

class RouteInfoTab extends StatelessWidget {
  final String locationName;
  final VoidCallback onClose;
  final ScrollController scrollController;
  final Future<void> Function() onStartRoute;
  final List<Map<String, dynamic>?> routeInfos;
  final RouteRiskCalculator routeRiskCalculator; // Nuevo parámetro
  final List<List<LatLng>> routes; // Lista de rutas
  final Set<Marker> markers; // Marcadores para calcular reportes
  final bool showRouteDetails; // Nuevo parámetro
  final int selectedRouteIndex; // Índice de la ruta seleccionada

  RouteInfoTab({
    required this.locationName,
    required this.onClose,
    required this.scrollController,
    required this.onStartRoute,
    required this.routeInfos,
    required this.routeRiskCalculator, // Nuevo parámetro requerido
    required this.routes, // Rutas pasadas al widget
    required this.markers, // Marcadores pasados al widget
    required this.showRouteDetails, // Nuevo parámetro requerido
    required this.selectedRouteIndex,
  });

  @override
  Widget build(BuildContext context) {
    final hasRouteDetails = routeInfos.isNotEmpty && showRouteDetails;
    final Map<String, dynamic>? activeRouteData = _generateReportForSelectedRoute();
    return SingleChildScrollView(
      controller: scrollController,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: paletteColors.secondColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.only(top: 5, bottom: 15),
                    decoration: BoxDecoration(
                      color: paletteColors.thirdColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  locationName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await onStartRoute();
                        print("Información de rutas: ");
                        print(routeInfos); // Verifica que los datos estén en el formato esperado
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: paletteColors.thirdColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      child: Text(
                        'Iniciar ruta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    if (hasRouteDetails && activeRouteData != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: paletteColors.fourthColor,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '${activeRouteData['distance'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 18,
                              color: paletteColors.fourthColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: paletteColors.fourthColor,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          Text(
                            _formatDuration(activeRouteData['duration']),
                            style: TextStyle(
                              fontSize: 18,
                              color: paletteColors.fourthColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.report_outlined,
                            color: paletteColors.fourthColor,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '${activeRouteData['reportCount']}', // Mostrar reportes de la ruta activa
                            style: TextStyle(
                              fontSize: 18,
                              color: paletteColors.fourthColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
          Positioned(
            top: 15,
            right: 20,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: paletteColors.thirdColor
                      .withOpacity(0.4), // Fondo del círculo
                  shape: BoxShape.circle, // Forma circular
                ),
                child: Icon(
                  Icons.close,
                  color: paletteColors.cancelColor, // Color del ícono
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generar datos únicamente para la ruta seleccionada
  Map<String, dynamic>? _generateReportForSelectedRoute() {
    if (selectedRouteIndex < 0 || selectedRouteIndex >= routes.length) {
      return null; // Índice fuera de rango
    }

    final route = routes[selectedRouteIndex];
    double riskScore = routeRiskCalculator.calculateRouteRisk(route, markers);
    int reportCount = markers.where((marker) {
      double distance = routeRiskCalculator.calculateDistanceUseCase.execute(
        marker.position,
        route.first,
      );
      return distance <= 50.0; // Umbral de proximidad
    }).toSet().length; // Evitar duplicados

    return {
      'index': selectedRouteIndex + 1,
      'riskScore': riskScore,
      'reportCount': reportCount,
      'distance': routeInfos[selectedRouteIndex]?['distance'],
      'duration': routeInfos[selectedRouteIndex]?['duration'],
    };
  }

  // Función para formatear la duración
  // Función para formatear la duración
  String _formatDuration(String? duration) {
    if (duration == null || duration.isEmpty || duration == 'N/A') return 'N/A';

    // Patrón para capturar semanas o días, ignorando horas y minutos
    final regexWeeksDays = RegExp(r'(\d+)\s*(weeks?|days?)');
    final matchWeeksDays = regexWeeksDays.firstMatch(duration);

    if (matchWeeksDays != null) {
      // Si contiene semanas o días, retornar eso exclusivamente
      final value = matchWeeksDays.group(1) ?? '0';
      final unit = matchWeeksDays.group(2) ?? '';
      return '$value $unit';
    }

    // Patrón para capturar horas y minutos si no hay semanas o días
    final regexHoursMinutes = RegExp(r'(\d+)\s*hour.*?(\d+)?\s*min.*');
    final matchHoursMinutes = regexHoursMinutes.firstMatch(duration);

    if (matchHoursMinutes != null) {
      // Extraer horas y minutos
      final hours = int.tryParse(matchHoursMinutes.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(matchHoursMinutes.group(2) ?? '0') ?? 0;

      // Formatear en "h min" si ambas partes están presentes
      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}min';
      } else if (hours > 0) {
        return '${hours}h';
      } else if (minutes > 0) {
        return '${minutes}min';
      }
    }

    // Si no coincide con el formato esperado, retornar el texto original
    return duration;
  }
}
