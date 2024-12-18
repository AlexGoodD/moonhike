import 'package:moonhike/imports.dart';

class ReportsService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const cooldownDuration = Duration(minutes: 5);
  final Map<String, DateTime> cooldownTracker = {};

  Future<void> createReport(String userEmail, LatLng position, String reportType, String note) async {
    // Redondear las coordenadas para simplificar la clave del mapa
    String locationKey = '${position.latitude.toStringAsFixed(3)},${position.longitude.toStringAsFixed(3)}';

    DateTime now = DateTime.now();

    // Verificar cooldown
    if (cooldownTracker.containsKey(locationKey)) {
      DateTime lastReportTime = cooldownTracker[locationKey]!;
      if (now.difference(lastReportTime) < cooldownDuration) {
        int remainingTime = cooldownDuration.inMinutes - now.difference(lastReportTime).inMinutes;
        throw Exception('Espera $remainingTime minutos antes de crear otro reporte en esta ubicación.');
      }
    }

    // Crear el reporte
    await firestore.collection('reports').add({
      'user': userEmail,
      'location': GeoPoint(position.latitude, position.longitude),
      'timestamp': FieldValue.serverTimestamp(),
      'type': reportType,
      'note': note,
    });

    // Actualizar el cooldown
    cooldownTracker[locationKey] = now;
  }

  /// Nuevo método para crear reportes desde noticias y definir su eliminación en 24 horas.
  Future<void> createReportFromNews({
    required String type,
    required String note,
    required GeoPoint location,
    required DateTime expiration,
  }) async {
    print("Creando reporte desde noticia: $note");
    print("Ubicación: ${location.latitude}, ${location.longitude}");
    print("Expiración: $expiration");

    // Valida los datos antes de crear el reporte
    if (note.isEmpty) {
      print("Error: El reporte no tiene una nota válida.");
      return;
    }

    if (type.isEmpty) {
      print("Error: El reporte no tiene un tipo válido.");
      return;
    }

    await firestore.collection('reports').add({
      'type': type,
      'note': note,
      'location': location,
      'createdAt': DateTime.now(),
      'expiresAt': expiration,
    });

    print("Reporte creado con éxito desde noticia.");
  }

  /// Elimina reportes cuya fecha de expiración ha pasado.
  Future<void> deleteExpiredReports() async {
    final now = DateTime.now();
    final expiredReports = await firestore
        .collection('reports')
        .where('expiresAt', isLessThan: now) // Cambiado a 'expiresAt'
        .get();

    for (var doc in expiredReports.docs) {
      await doc.reference.delete();
    }

    print("Reportes expirados eliminados: ${expiredReports.docs.length}");
  }

  Stream<List<Report>> getReports() {
    return firestore.collection('reports').snapshots().map((snapshot) {
      List<Report> reports = snapshot.docs.map((doc) => Report.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
      print("Número de reportes obtenidos de Firestore: ${reports.length}");
      return reports;
    });
  }

  Future<void> deleteReport(String reportId) async {
    await firestore.collection('reports').doc(reportId).delete();
  }

  Stream<QuerySnapshot> listenToReportChanges() {
    return firestore.collection('reports').snapshots();
  }
}