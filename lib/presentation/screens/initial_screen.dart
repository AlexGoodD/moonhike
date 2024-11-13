// Este archivo es la pantalla inicial que decide si se redirige al usuario a LoginPage o MapScreen.
import 'package:moonhike/imports.dart';

class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Muestra un indicador de carga mientras se espera el resultado
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // Si el usuario está autenticado, redirige a MapScreen
          return MapScreen();
        } else {
          // Si no está autenticado, redirige a LoginPage
          return LoginPage();
        }
      },
    );
  }
}