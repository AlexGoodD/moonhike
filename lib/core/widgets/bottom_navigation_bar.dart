import 'package:moonhike/imports.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (int index) {
        onTap(index); // Llama a la función de callback 'onTap' para actualizar el índice
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
