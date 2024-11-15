import 'package:moonhike/imports.dart';

class RouteInfoTab extends StatelessWidget {
  final String locationName;
  final VoidCallback onClose;
  final ScrollController scrollController;
  final Future<void> Function() onStartRoute;
  final List<Map<String, dynamic>?> routeInfos;
  final List<double> routeRiskScores;
  final bool showRouteDetails; // Nuevo parámetro

  RouteInfoTab({
    required this.locationName,
    required this.onClose,
    required this.scrollController,
    required this.onStartRoute,
    required this.routeInfos,
    required this.routeRiskScores,
    required this.showRouteDetails, // Nuevo parámetro requerido
  });

  // Método para obtener el color del indicador de calidad basado en el puntaje de riesgo
  Color _getQualityColor(double riskScore) {
    if (riskScore < 10) return Colors.green;
    if (riskScore <= 20) return Colors.yellow;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
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
            SizedBox(height: 15),
            if (showRouteDetails && routeInfos.isNotEmpty && routeRiskScores.isNotEmpty)
              ListView.builder(
                controller: scrollController, // Usa el mismo controlador
                shrinkWrap: true, // Evita overflow
                itemCount: routeInfos.length,
                itemBuilder: (context, index) {
                  var riskScore = routeRiskScores[index];
                  var qualityColor = _getQualityColor(riskScore);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ruta ${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: qualityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}