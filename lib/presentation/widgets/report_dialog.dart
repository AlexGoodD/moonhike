import 'package:flutter/material.dart';
import 'package:moonhike/imports.dart';

class ReportDialog extends StatefulWidget {
  final Function(String, String) onReportTypeSelected;

  ReportDialog({required this.onReportTypeSelected});

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String note = ""; // Almacena la nota escrita por el usuario

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [SettingsColor.backgroundTop, SettingsColor.backgroundBottom],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecciona el tipo de reporte',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              ListTile(
                trailing: Icon(
                  Icons.lightbulb,
                  color: Color.fromARGB(255, 255, 165, 82), // Cambia el color del ícono
                ),
                title: Text(
                  'Mala iluminación',
                  style: TextStyle(
                    color: Colors.white, // Cambia el color del texto
                    fontWeight: FontWeight.bold, // Opcional: estilo de fuente
                  ),
                ),
                onTap: () => widget.onReportTypeSelected('Mala iluminación', note),
              ),
              ListTile(
                trailing: Icon(
                  Icons.warning,
                  color: Colors.red, // Cambia el color del ícono
                ),
                title: Text(
                  'Inseguridad',
                  style: TextStyle(
                    color: Colors.white, // Cambia el color del texto
                    fontWeight: FontWeight.bold, // Opcional: estilo de fuente
                  ),
                ),
                onTap: () => widget.onReportTypeSelected('Inseguridad', note),
              ),
              ListTile(
                trailing: Icon(
                  Icons.directions_walk,
                  color: Color.fromARGB(255, 108, 92, 255), // Cambia el color del ícono
                ),
                title: Text(
                  'Interés peatonal',
                  style: TextStyle(
                    color: Colors.white, // Cambia el color del texto
                    fontWeight: FontWeight.bold, // Opcional: estilo de fuente
                  ),
                ),
                onTap: () => widget.onReportTypeSelected('Interés peatonal', note),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.buttonIcon, // Fondo del botón
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Espaciado interno
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Bordes redondeados
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.white, // Color del texto
                      fontWeight: FontWeight.bold, // Opcional: texto en negritas
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}