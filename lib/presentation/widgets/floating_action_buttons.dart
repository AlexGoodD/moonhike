import 'package:moonhike/imports.dart';

class FloatingActionButtons extends StatelessWidget {
  final Future<void> Function() onStartRoute;
  final Future<void> Function() onCreateReport;
  final bool showStartRouteButton;

  FloatingActionButtons({
    required this.onStartRoute,
    required this.onCreateReport,
    required this.showStartRouteButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 86, 86, 174), const Color.fromARGB(255, 53, 36, 140)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FloatingActionButton(
            onPressed: () async {
              await onCreateReport();
            },
            child: Icon(
              Boxicons.bx_map_pin,
              size: 36.0, // Tamaño del icono
              color: Colors.white, // Color del icono
            ),
            backgroundColor: Colors.transparent, // Hace que el fondo del FAB sea transparente
            elevation: 0, // Quita la sombra si no es necesaria
            heroTag: 'createReport',
          ),
        ),
      ],
    );
  }
}