import 'package:flutter/material.dart';
import 'package:moonhike/imports.dart';

class CustomScreen extends StatefulWidget {
  @override
  _CustomScreenState createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  // Colores seleccionados para cada tipo de reporte
  Color colorMalaIluminacion = Colors.orange;
  Color colorInseguridad = Colors.purple;
  Color colorInteres = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ReportsScreenColors.backgroundTop, // Color inicial del degradado
            ReportsScreenColors.backgroundBottom, // Color final del degradado
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Hace el fondo del Scaffold transparente
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text('Personalización', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent, // AppBar transparente
          elevation: 0, // Sin sombra en el AppBar
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                Icon(Icons.color_lens, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Cambia los colores de los reportes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Reporte de mala iluminación
            _buildColorCard(
              'Reporte de mala iluminación',
              colorMalaIluminacion,
              [
                _buildColorOption(Colors.orange, () {
                  setState(() {
                    colorMalaIluminacion = Colors.orange;
                  });
                }),
                _buildColorOption(Colors.brown, () {
                  setState(() {
                    colorMalaIluminacion = Colors.brown;
                  });
                }),
                _buildColorOption(Colors.yellow, () {
                  setState(() {
                    colorMalaIluminacion = Colors.yellow;
                  });
                }),
              ],
              Icons.location_on, // Ícono para el tipo de reporte
              const Color.fromARGB(255, 171, 129, 45), // Color del ícono
            ),
            SizedBox(height: 20),

            // Reporte de inseguridad
            _buildColorCard(
              'Reporte de inseguridad',
              colorInseguridad,
              [
                _buildColorOption(Colors.purple, () {
                  setState(() {
                    colorInseguridad = Colors.purple;
                  });
                }),
                _buildColorOption(Colors.orange, () {
                  setState(() {
                    colorInseguridad = Colors.orange;
                  });
                }),
                _buildColorOption(Colors.blue, () {
                  setState(() {
                    colorInseguridad = Colors.blue;
                  });
                }),
              ],
              Icons.security, // Ícono para el tipo de reporte
              Colors.purple, // Color del ícono
            ),
            SizedBox(height: 20),

            // Reporte de interés
            _buildColorCard(
              'Reporte de interés',
              colorInteres,
              [
                _buildColorOption(Colors.red, () {
                  setState(() {
                    colorInteres = Colors.red;
                  });
                }),
                _buildColorOption(Colors.green, () {
                  setState(() {
                    colorInteres = Colors.green;
                  });
                }),
                _buildColorOption(Colors.lightBlue, () {
                  setState(() {
                    colorInteres = Colors.lightBlue;
                  });
                }),
              ],
              Icons.directions_walk, // Ícono para el tipo de reporte
              Colors.red, // Color del ícono
            ),
          ],
        ),
      ),
    );
  }

  // Widget para crear un card de color personalizado
  Widget _buildColorCard(String title, Color selectedColor, List<Widget> colorOptions, IconData icon, Color iconColor) {
    return Card(
      color: ReportsScreenColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(children: colorOptions),
                ],
              ),
            ),
            Icon(icon, color: iconColor, size: 40),
          ],
        ),
      ),
    );
  }

  // Widget para crear opciones de colores
  Widget _buildColorOption(Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 10),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
