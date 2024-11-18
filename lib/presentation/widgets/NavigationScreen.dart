import 'package:flutter/material.dart';
import 'package:moonhike/imports.dart';

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;

  // Lista de pantallas para el IndexedStack
  final List<Widget> _pages = [
    MapScreen(),
    ReportsScreen(), // ReportsScreen se reconstruye cada vez que se selecciona
    SettingsScreen(), // SettingsScreen se reconstruye cada vez que se selecciona
    ProfileScreen(), // ProfileScreen se reconstruye cada vez que se selecciona
  ];

  // Lógica para manejar la navegación en el BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (int i = 0; i < _pages.length; i++)
          // Cada pantalla se actualiza cada vez que es seleccionada
            if (i == _currentIndex)
              Builder(
                builder: (context) {
                  if (i == 1) return ReportsScreen(); // Reconstruye ReportsScreen
                  if (i == 2) return SettingsScreen(); // Reconstruye SettingsScreen
                  if (i == 3) return ProfileScreen(); // Reconstruye ProfileScreen
                  return _pages[i]; // Mantiene MapScreen en caché
                },
              )
            else
              Offstage(child: _pages[i]), // Mantiene las otras pantallas ocultas
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: paletteColors.secondColor,
        selectedItemColor: paletteColors.fourthColor,
        unselectedItemColor: const Color.fromARGB(149, 153, 151, 188),
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
      ),
    );
  }
}