import 'package:moonhike/imports.dart';

class UserService {
  Future<String?> getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userUID');
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }
}