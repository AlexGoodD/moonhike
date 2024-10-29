import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  final Function(String, String) onReportSaved;

  ReportDialog({required this.onReportSaved});

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? selectedReportType;
  TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Crear reporte de la comunidad'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selección del tipo de reporte
          ListTile(
            leading: Icon(Icons.lightbulb),
            title: Text('Mala iluminación'),
            onTap: () {
              setState(() {
                selectedReportType = 'mala iluminación';
              });
            },
            selected: selectedReportType == 'mala iluminación',
          ),
          ListTile(
            leading: Icon(Icons.warning),
            title: Text('Inseguridad'),
            onTap: () {
              setState(() {
                selectedReportType = 'inseguridad';
              });
            },
            selected: selectedReportType == 'inseguridad',
          ),
          ListTile(
            leading: Icon(Icons.directions_walk),
            title: Text('Interés peatonal'),
            onTap: () {
              setState(() {
                selectedReportType = 'interés peatonal';
              });
            },
            selected: selectedReportType == 'interés peatonal',
          ),
          SizedBox(height: 10),
          // Campo para agregar una nota opcional
          TextField(
            controller: noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Nota (opcional)',
              hintText: 'Añade detalles adicionales...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedReportType != null) {
              // Llama a la función de guardar en el controlador
              widget.onReportSaved(selectedReportType!, noteController.text);
              Navigator.of(context).pop(); // Cierra el diálogo
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor selecciona un tipo de reporte.')),
              );
            }
          },
          child: Text('Guardar reporte'),
        ),
      ],
    );
  }
}
