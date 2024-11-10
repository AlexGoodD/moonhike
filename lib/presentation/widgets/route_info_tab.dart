import 'package:moonhike/imports.dart';

class RouteInfoTab extends StatelessWidget {
  final String? duration;
  final String? distance;

  RouteInfoTab({this.duration, this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.white.withOpacity(0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (duration != null && distance != null) ...[
            Text(
              'Duración estimada: $duration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Distancia: $distance',
              style: TextStyle(fontSize: 14),
            ),
          ] else
            Text(
              'Cargando información...',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}