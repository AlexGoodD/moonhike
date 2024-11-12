//Archivo que se ejecuta al iniciar la aplicación
import 'imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoonHike',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Cargando
          } else if (snapshot.hasData) {
            return MapScreen(); // Usuario autenticado, va a la pantalla principal
          } else {
            return LoginPage(); // No autenticado, va a la pantalla de login
          }
        },
      ),
    );
  }
}
