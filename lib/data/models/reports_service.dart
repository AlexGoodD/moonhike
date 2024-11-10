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

  Stream<List<Report>> getReports() {
    return firestore.collection('reports').snapshots().map((snapshot) {
      List<Report> reports = snapshot.docs.map((doc) => Report.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
      print("Número de reportes obtenidos de Firestore: ${reports.length}");
      return reports;
    });
  }

  Stream<QuerySnapshot> listenToReportChanges() {
    return firestore.collection('reports').snapshots();
  }
}