import 'package:moonhike/imports.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

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
        backgroundColor: Colors.transparent,
        // Hace el fondo del Scaffold transparente
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80), // Ajusta la altura del AppBar
          child: AppBar(
            automaticallyImplyLeading: false,
            // Evita el botón de regreso automático
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
            backgroundColor: Colors.transparent,
            // Hace el AppBar transparente
            elevation: 0, // Remueve la sombra del AppBar
          ),
        ),
        body: Center(
        ),
      ),
    );
  }
}

