import 'package:intl/intl.dart';
import 'package:moonhike/imports.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final User? user = FirebaseAuth.instance.currentUser; // Usuario autenticado
  List<QueryDocumentSnapshot>? userReports; // Lista de reportes del usuario
  bool isLoading = true; // Bandera para indicar si los datos se están cargando
  Timer? _snackBarTimer; // Timer para controlar los SnackBar

  @override
  void initState() {
    super.initState();
    _fetchUserReports(); // Llama a la función para obtener los reportes del usuario
  }

  Future<void> _fetchUserReports() async {
    if (user != null) {
      QuerySnapshot reportSnapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('user', isEqualTo: user!.email) // Check if user is non-null
          .get();

      if (mounted) {
        setState(() {
          userReports = reportSnapshot.docs; // Asigna los reportes obtenidos
          isLoading = false; // Termina la carga
        });
      }
    } else {
      setState(() {
        isLoading = false; // Stop loading if user is null
        userReports = []; // Set userReports to an empty list
      });
    }
  }

  Future<void> _deleteReport(String reportId) async {
    try {
      await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();

      // Cancelamos cualquier SnackBar pendiente
      _snackBarTimer?.cancel();

      // Programamos un nuevo SnackBar después de 500ms
      _snackBarTimer = Timer(Duration(milliseconds: 1000), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle, // Ícono de una palomita
                  color: Colors.white, // Color del ícono
                ),
                SizedBox(width: 10), // Espacio entre el ícono y el texto
                Text(
                  'Reportes eliminados exitosamente',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            behavior: SnackBarBehavior.fixed,
            backgroundColor: paletteColors.sevenColor,
          ),
        );
      });

      _fetchUserReports(); // Refresca la lista de reportes
    } catch (e) {
      // Si ocurre un error, también cancelamos cualquier SnackBar pendiente
      _snackBarTimer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error, // Ícono de una palomita
                color: Colors.white, // Color del ícono
              ),
              SizedBox(width: 10), // Espacio entre el ícono y el texto
              Text(
                'Error al eliminar el reporte: $e',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.redAccent,),
      );
    }
  }

  @override
  void dispose() {
    _snackBarTimer?.cancel(); // Cancelamos el Timer cuando se destruye el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ReportsScreenColors.backgroundTop,
              ReportsScreenColors.backgroundBottom,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Mis Reportes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : userReports == null || userReports!.isEmpty
              ? Center(
            child: Text(
              'No has realizado reportes',
              style: TextStyle(
                fontSize: 18,
                color: ReportsScreenColors.primaryFontColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : ListView.builder(
            itemCount: userReports!.length,
            itemBuilder: (context, index) {
              final report = userReports![index];
              final reportData = report.data() as Map<String, dynamic>;
              final reportId = report.id;
              final reportType = reportData['type'] ?? 'Sin especificar';
              final timestamp = reportData['timestamp'] as Timestamp;
              final formattedDate = DateFormat('dd/MM/yyyy').format(timestamp.toDate());

              // Selecciona el icono basado en el tipo de reporte
              IconData reportIcon;
              switch (reportType) {
                case 'Mala iluminación':
                  reportIcon = Icons.lightbulb;
                  break;
                case 'Inseguridad':
                  reportIcon = Icons.warning;
                  break;
                case 'Interés peatonal':
                  reportIcon = Icons.directions_walk;
                  break;
                default:
                  reportIcon = Icons.report;
                  break;
              }

              return ListTile(
                leading: Icon(
                  reportIcon,
                  color: ReportsScreenColors.iconColor,
                  size: 30,
                ),
                title: Text(
                  reportType,
                  style: TextStyle(
                    color: ReportsScreenColors.primaryFontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha: $formattedDate',
                      style: TextStyle(
                        color: ReportsScreenColors.secondaryFontColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: ReportsScreenColors.iconColor, size: 24),
                  onPressed: () => showDeleteConfirmationDialog(context, reportId),
                ),
                isThreeLine: true,
              );
            },
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: 1, // Índice actual para la pantalla de Configuración
            onTap: (index) {}, // No necesitas ninguna lógica extra aquí
          ),
        )
    );
  }

  void showDeleteConfirmationDialog(BuildContext parentContext, String reportId) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: paletteColors.secondColor, // Color de fondo del diálogo
          title: Text(
            "Eliminar reporte",
            style: TextStyle(
              color: Colors.white, // Color del texto del título
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "¿Estás seguro de que deseas eliminar este reporte?",
            style: TextStyle(
              color: paletteColors.fourthColor, // Color del texto del contenido
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancelar",
                style: TextStyle(
                  color: paletteColors.cancelColor,
                  fontWeight: FontWeight.normal,
                ), // Color del botón "Cancelar"
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteReport(reportId); // Llama a la función de eliminación
              },
              child: Text(
                "Eliminar",
                style: TextStyle(
                  color: paletteColors.deleteColor,
                  fontWeight: FontWeight.bold,
                ), // Color del botón "Eliminar"
              ),
            ),
          ],
        );
      },
    );
  }
}