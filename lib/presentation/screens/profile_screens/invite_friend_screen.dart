import 'package:moonhike/imports.dart';

class InviteFriendScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invita a un amigo/a'),
      ),
      body: Center(
        child: Text(
          'Comparte MoonHike con tus amigos y familiares.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
