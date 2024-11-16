import 'package:moonhike/imports.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true; // Estado inicial de las notificaciones

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
                'Configuración',
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
        body: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Sección de cuenta
            Text(
              'Cuenta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10), // Curva en los bordes
                ),
                padding: EdgeInsets.all(8.0), // Espaciado alrededor del ícono
                child: Icon(Icons.person, color: AppColors.buttonIcon),
              ),
              title: Text('Configuración de cuenta', style: TextStyle(color: Colors.white)),
              subtitle: Text('Actualiza y edita tu información personal', style: TextStyle(color: const Color.fromARGB(115, 255, 255, 255))),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountConfigScreen()), // Navegación a la página de configuración de cuenta
                );
              },
              tileColor: ReportsScreenColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            // Sección General
            Text(
              'General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.lock, color: AppColors.buttonIcon),
              ),
              title: Text('Permisos', style: TextStyle(color: Colors.white)),
              subtitle: Text('Controla qué permisos obtiene MoonHike', style: TextStyle(color: const Color.fromARGB(115, 255, 255, 255))),
              onTap: () {
                AppSettings.openAppSettings(); // Abre la configuración de la app
              },
              tileColor: ReportsScreenColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: 2, // Índice actual para la pantalla de Configuración
          onTap: (index) {}, // No necesitas ninguna lógica extra aquí
        ),
      ),
    );
  }
}
