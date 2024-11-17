import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moonhike/imports.dart';
import 'package:google_geocoding/google_geocoding.dart'; // Importa el paquete de geocodificación
import 'package:flutter_langdetect/flutter_langdetect.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();

  final String _baseUrl = 'http://api.mediastack.com/v1/news';
  final Set<String> processedArticles = {}; // IDs de noticias ya procesadas
  Timer? _timer;

  late ReportsService reportService;
  late String geocodingApiKey;
  late String mediaStackApiKey;

  factory NewsService({
    required ReportsService reportService,
    required String geocodingApiKey,
    required String mediaStackApiKey,
  }) {
    _instance.reportService = reportService;
    _instance.geocodingApiKey = geocodingApiKey;
    _instance.mediaStackApiKey = mediaStackApiKey;
    return _instance;
  }

  NewsService._internal() {
    // Inicializa el detector de idiomas solo una vez
    initLangDetect();
  }

  Future<void> fetchAndCreateReports({required String query}) async {
    // Palabras clave para filtrar las noticias
    final List<String> keywords = [
      'asalto',
      'robo',
      'secuestro',
      'balacera',
      'homicidio',
    ];
    final String combinedQuery = keywords.join(',');
    final Uri url = Uri.parse(
      '$_baseUrl?access_key=$mediaStackApiKey&countries=mx&languages=es&keywords=$combinedQuery',
    );

    try {
      // Realizar la llamada a la API
      print("Llamando a la API...");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List articles = data['data'] ?? [];

        // Verificar si hay artículos disponibles
        if (articles.isEmpty) {
          print("No se encontraron artículos relevantes.");
          return;
        }

        // Procesar cada artículo
        for (var article in articles) {
          // Crear un ID único para la noticia
          final String articleId = generateArticleId(article);

          // Verificar si la noticia ya fue procesada
          if (await isArticleProcessed(articleId)) {
            print("Noticia ya procesada: $articleId");
            continue;
          }

          // Extraer detalles de la noticia
          final title = article['title'] ?? '';
          final note = article['description'] ?? '';
          final publishedAt = DateTime.tryParse(article['published_at'] ?? '') ?? DateTime.now();

          // Filtrar artículos sin título ni descripción
          if (title.isEmpty && note.isEmpty) {
            print("Título y descripción vacíos, omitiendo esta noticia.");
            continue;
          }

          final content = "$title $note";

          // Filtrar artículos que no están en español
          if (!_isSpanish(content)) {
            print("Noticia no está en español: $title");
            continue;
          }

          // Intentar geocodificar el contenido de la noticia
          print("Intentando obtener ubicación para: $title");
          final location = await getLocationFromText(content);

          // Crear reporte si se encuentra la ubicación
          if (location != null) {
            await reportService.createReportFromNews(
              type: 'Inseguridad',
              note: title,
              location: location,
              expiration: publishedAt.add(Duration(days: 1)),
            );

            // Marcar la noticia como procesada
            await markArticleAsProcessed(articleId);

            print("Reporte creado exitosamente para la noticia: $title");
          } else {
            print("No se pudo determinar la ubicación para la noticia: $title");
          }
        }
      } else {
        print("Error al obtener noticias: ${response.statusCode}");
        throw Exception('Error al obtener noticias: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en fetchAndCreateReports: $e');
    }

    // Esperar 5 minutos antes de la próxima llamada
    print("Esperando 5 minutos para la próxima llamada...");
    await Future.delayed(Duration(minutes: 5));
  }

  String generateArticleId(Map<String, dynamic> article) {
    final title = article['title'] ?? '';
    final description = article['description'] ?? '';
    final publishedAt = article['published_at'] ?? '';

    // Combina título, descripción y fecha para crear un hash único
    final uniqueString = '$title$description$publishedAt';
    return uniqueString.hashCode.toString();
  }

  Future<bool> isArticleProcessed(String articleId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('processed_articles')
        .doc(articleId)
        .get();

    return snapshot.exists;
  }

  Future<void> markArticleAsProcessed(String articleId) async {
    await FirebaseFirestore.instance
        .collection('processed_articles')
        .doc(articleId)
        .set({'processedAt': FieldValue.serverTimestamp()});
  }

  /// Filtra contenido en español
  bool _isSpanish(String text) {
    try {
      final detectedLang = detect(text);
      return detectedLang == 'es';
    } catch (e) {
      print("Error detectando idioma: $e");
      return false; // Si hay error, asume que no es español
    }
  }

  /// Inicia el proceso de peticiones cada 5 minutos
  void startFetchingReportsPeriodically(String query) {
    _timer = Timer.periodic(Duration(minutes: 5), (_) async {
      print("Ejecutando petición...");
      await fetchAndCreateReports(query: query);
    });

    // Realiza la primera petición inmediatamente
    print("Ejecutando primera petición inmediatamente...");
    fetchAndCreateReports(query: query);
  }

  /// Detiene las peticiones periódicas
  void stopFetchingReportsPeriodically() {
    _timer?.cancel();
    print("Peticiones periódicas detenidas.");
  }

  /// Obtiene la ubicación (GeoPoint) desde una cadena de texto usando Google Geocoding API.
  Future<GeoPoint?> getLocationFromText(String text) async {
    final googleGeocoding = GoogleGeocoding(geocodingApiKey);

    final geocodingResult = await googleGeocoding.geocoding.get(text, []);

    if (geocodingResult != null && geocodingResult.results != null && geocodingResult.results!.isNotEmpty) {
      final location = geocodingResult.results!.first.geometry?.location;
      if (location != null && location.lat != null && location.lng != null) {
        return GeoPoint(location.lat!, location.lng!);
      }
    }
    return null;
  }
}