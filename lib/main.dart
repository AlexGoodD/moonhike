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
      home: InitialScreen(), // Usa InitialScreen como la pantalla de inicio
    );
  }
}