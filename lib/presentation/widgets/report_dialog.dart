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
  String? selectedReportType; // Almacena el tipo de reporte seleccionado

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
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
              SizedBox(height: 10),
              RadioListTile<String>(
                value: 'Mala iluminación',
                groupValue: selectedReportType,
                title: Text('Mala iluminación', style: TextStyle(color: Colors.white)),
                secondary: Icon(Boxicons.bx_bulb, color: const Color.fromARGB(255, 255, 165, 82)),
                onChanged: (value) {
                  setState(() {
                    selectedReportType = value;
                  });
                },
              ),
              RadioListTile<String>(
                value: 'Inseguridad',
                groupValue: selectedReportType,
                title: Text('Inseguridad', style: TextStyle(color: Colors.white)),
                secondary: Icon(Boxicons.bx_dislike, color: const Color.fromARGB(255, 108, 92, 255)),
                onChanged: (value) {
                  setState(() {
                    selectedReportType = value;
                  });
                },
              ),
              RadioListTile<String>(
                value: 'Interés peatonal',
                groupValue: selectedReportType,
                title: Text('Interés peatonal', style: TextStyle(color: Colors.white)),
                secondary: Icon(Icons.directions_walk, color: const Color.fromARGB(255, 255, 79, 79)),
                onChanged: (value) {
                  setState(() {
                    selectedReportType = value;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nota (opcional)',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(66, 255, 255, 255)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(105, 255, 255, 255)),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    note = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: selectedReportType != null
                        ? () {
                            widget.onReportTypeSelected(selectedReportType!, note);
                            Navigator.of(context).pop();
                          }
                        : null, // Botón deshabilitado si no hay una selección
                    child: Text('Subir reporte'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255), // Cambia el color si lo deseas
                      backgroundColor: AppColors.buttonIcon,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
