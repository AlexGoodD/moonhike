import 'package:moonhike/imports.dart';

class RouteInfoTab extends StatelessWidget {
  final String locationName;
  final VoidCallback onClose;
  final ScrollController scrollController;
  final Future<void> Function() onStartRoute;
  final List<Map<String, dynamic>?> routeInfos;
  final bool showRouteDetails; // Nuevo parámetro

  RouteInfoTab({
    required this.locationName,
    required this.onClose,
    required this.scrollController,
    required this.onStartRoute,
    required this.routeInfos,
    required this.showRouteDetails, // Nuevo parámetro requerido
  });

  @override
  Widget build(BuildContext context) {
    final hasRouteDetails = routeInfos.isNotEmpty && showRouteDetails;
    return SingleChildScrollView(
      controller: scrollController, // Vincula el controlador aquí
      child: Container(
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
                SizedBox(width: 22),
                if (hasRouteDetails)
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on, // Ícono para la distancia (puedes cambiarlo según prefieras)
                            color: paletteColors.fourthColor, // Color del ícono
                            size: 20, // Tamaño del ícono
                          ),
                          SizedBox(width: 5), // Espacio entre ícono y texto
                          Text(
                            '${routeInfos.first?['distance'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 18,
                              color: paletteColors.fourthColor, // Cambia el color aquí
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 25), // Espaciado entre distancia y duración
                      Row(
                        children: [
                          Icon(
                            Icons.access_time, // Ícono para duración
                            color: paletteColors.fourthColor, // Color del ícono
                            size: 20, // Tamaño del ícono
                          ),
                          SizedBox(width: 5), // Espacio entre los dos íconos
                          Text(
                            _formatDuration(routeInfos.first?['duration']),
                            style: TextStyle(
                              fontSize: 18,
                              color: paletteColors.fourthColor, // Cambia el color aquí
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  // Función para formatear la duración
  String _formatDuration(String? duration) {
    if (duration == null || duration == 'N/A') return 'N/A';
    final regex = RegExp(r'(\d+)\s*hour.*?(\d+)?\s*min.*');
    final match = regex.firstMatch(duration);

    if (match != null) {
      final hours = match.group(1) ?? '0';
      final minutes = match.group(2) ?? '0';
      return '${hours}h ${minutes}min';
    }

    return duration;
  }

}