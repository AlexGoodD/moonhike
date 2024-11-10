// lib/data/models/report.dart
import 'package:moonhike/imports.dart';

class Report {
  final String type;
  final LatLng location;
  final String user;
  final String? note;
  final DateTime? timestamp;

  Report({
    required this.type,
    required this.location,
    required this.user,
    this.note,
    this.timestamp,
  });

  // Método de fábrica para crear un objeto Report a partir de datos de Firestore
  factory Report.fromFirestore(Map<String, dynamic> data) {
    return Report(
      type: data['type'] ?? '',
      location: LatLng(data['location'].latitude, data['location'].longitude),
      user: data['user'] ?? 'Unknown User',
      note: data['note'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}