import 'package:moonhike/imports.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;

  MapWidget({required this.mapController});

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: mapController.currentPosition ?? LatLng(25.6866, -100.3161),
        zoom: 14.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        mapController.controller = controller;
      },
      markers: mapController.markers,
      circles: mapController.circles,
      polylines: mapController.polylines, // Asegúrate de incluir las polilíneas aquí
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}