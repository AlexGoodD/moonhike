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
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(), // Ruta para la página de login
        '/map': (context) => MapScreen(),   // Ruta para la pantalla principal
      },
      home: FutureBuilder(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Pantalla de carga
          } else if (snapshot.hasData) {
            return MapScreen(); // Usuario autenticado, redirige a la pantalla principal
          } else {
            return LoginPage(); // Usuario no autenticado, redirige a la pantalla de login
          }
        },
      ),
    );
  }
}
