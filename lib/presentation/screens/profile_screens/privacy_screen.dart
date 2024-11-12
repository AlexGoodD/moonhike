import 'package:moonhike/imports.dart';

class PrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacidad'),
      ),
      body: Center(
        child: Text(
          'Aquí podrás cambiar la configuración de privacidad.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
