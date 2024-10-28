// report_dialog.dart

import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  final Function(String, String) onReportSubmit;

  ReportDialog({required this.onReportSubmit});

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReportType;
  TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Crear Reporte de Comunidad'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedReportType,
            items: [
              DropdownMenuItem(
                value: 'falta de iluminación',
                child: Text('Falta de iluminación o zona oscura'),
              ),
              DropdownMenuItem(
                value: 'zona insegura',
                child: Text('Zona insegura o incidente delictivo'),
              ),
              DropdownMenuItem(
                value: 'sin accesibilidad',
                child: Text('Zona inaccesible para peatones'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedReportType = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Tipo de reporte',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Nota (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedReportType != null) {
              widget.onReportSubmit(_selectedReportType!, _noteController.text);
              Navigator.pop(context);
            } else {
              // Muestra un mensaje si no se selecciona un tipo de reporte
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, selecciona un tipo de reporte')),
              );
            }
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
