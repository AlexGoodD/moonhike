import 'package:moonhike/imports.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  void _navigateToScreen(int index, BuildContext context) {
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = MapScreen();
        break;
      case 1:
        nextScreen = ReportsScreen();
        break;
      case 2:
        nextScreen = SettingsScreen();
        break;
      case 3:
        nextScreen = ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 200), // Duración de la animación
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (int index) {
        if (index != currentIndex) {
          _navigateToScreen(index, context); // Navega solo si el índice cambia
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: paletteColors.secondColor, // Color de fondo de la barra
      selectedItemColor: paletteColors.fourthColor, // Color de los íconos y texto seleccionados
      unselectedItemColor: const Color.fromARGB(149, 153, 151, 188), // Color de los íconos y texto no seleccionados
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article),
          label: 'Mis reportes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configuración',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}