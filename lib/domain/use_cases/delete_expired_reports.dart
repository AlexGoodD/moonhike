import 'package:moonhike/imports.dart';

class DeleteExpiredReports {
  final ReportsService reportsService;

  DeleteExpiredReports({required this.reportsService});

  Future<void> execute() async {
    try {
      await reportsService.deleteExpiredReports();
      print('Reportes expirados eliminados correctamente.');
    } catch (e) {
      print('Error al eliminar reportes expirados: $e');
    }
  }
}