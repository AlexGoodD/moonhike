import 'package:moonhike/imports.dart';

class ReportsService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createReport(String userEmail, LatLng position, String reportType, String note) async {
    await firestore.collection('reports').add({
      'user': userEmail,
      'location': GeoPoint(position.latitude, position.longitude),
      'timestamp': FieldValue.serverTimestamp(),
      'type': reportType,
      'note': note,
    });
  }

  Stream<QuerySnapshot> listenToReportChanges() {
    return firestore.collection('reports').snapshots();
  }
}