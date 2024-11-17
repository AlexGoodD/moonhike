import 'package:moonhike/imports.dart';

class GenerateAutomatedReport {
  final NewsService newsService;

  GenerateAutomatedReport({required this.newsService});

  /// Genera reportes automatizados basados en noticias.
  Future<void> execute({String? query}) async {
    try {
      // Define una consulta predeterminada si `query` es nulo
      final defaultKeywords = [
        'asalto',
        'robo',
        'violencia',
        'secuestro',
        'balacera',
        'crimen',
        'homicidio',
        'México'
      ];
      final searchQuery = query ?? defaultKeywords.join(' OR ');

      await newsService.fetchAndCreateReports(query: searchQuery);
      print('Reportes automatizados generados correctamente.');
    } catch (e) {
      print('Error al generar reportes automatizados: $e');
    }
  }
}