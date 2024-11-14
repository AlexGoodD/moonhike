import 'package:intl/intl.dart';
import 'package:moonhike/imports.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final User? user = FirebaseAuth.instance.currentUser; // Usuario autenticado
  int _selectedIndex = 1; // Índice de la pantalla actual (Reports)
  List<QueryDocumentSnapshot>? userReports; // Lista de reportes del usuario
  bool isLoading = true; // Bandera para indicar si los datos se están cargando

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reporte eliminado exitosamente')),
      );
      _fetchUserReports(); // Refresca la lista de reportes después de la eliminación
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el reporte: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ReportsScreenColors.backgroundTop, // Color inicial del degradado
              ReportsScreenColors.backgroundBottom, // Color final del degradado
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent, // Hace el fondo del Scaffold transparente
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(80), // Ajusta la altura del AppBar
            child: AppBar(
              automaticallyImplyLeading: false, // Evita el botón de regreso automático
              title: Padding(
                padding: EdgeInsets.only(top: 20.0), // Baja el texto más abajo
                child: Text(
                  'Mis Reportes',
                  style: TextStyle(
                    color: Colors.white, // Texto en color blanco
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent, // Hace el AppBar transparente
              elevation: 0, // Remueve la sombra del AppBar
            ),
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : userReports == null || userReports!.isEmpty
              ? Center(
            child: Text(
              'No has realizado reportes',
              style: TextStyle(
                fontSize: 18, // Tamaño del texto
                color: ReportsScreenColors.primaryFontColor, // Color del texto
                fontWeight: FontWeight.bold, // Peso del texto
              ),
            ),
          )
              : ListView.builder(
            itemCount: userReports!.length,
            itemBuilder: (context, index) {
              final report = userReports![index];
              final reportData = report.data() as Map<String, dynamic>;
              final reportId = report.id; // ID del reporte
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
                case 'Poca vialidad peatonal':
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
                  icon: Icon(Icons.close, color: ReportsScreenColors.iconColor, size: 24), // Icono de eliminación en color rojo
                  onPressed: () => _deleteReport(reportId), // Llama a la función de eliminación con el reportId
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
}