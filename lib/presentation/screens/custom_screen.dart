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
            // Título de sección
            Text(
              'Cambia los colores de los reportes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),

            // Reporte de mala iluminación
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reporte de mala iluminación', style: TextStyle(color: Colors.white)),
                Row(
                  children: [
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
                ),
              ],
            ),
            SizedBox(height: 20),

            // Reporte de inseguridad
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reporte de inseguridad', style: TextStyle(color: Colors.white)),
                Row(
                  children: [
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
                ),
              ],
            ),
            SizedBox(height: 20),

            // Reporte de interés
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reporte de interés', style: TextStyle(color: Colors.white)),
                Row(
                  children: [
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
                ),
              ],
            ),
            SizedBox(height: 20),
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
