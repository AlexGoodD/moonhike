import 'package:flutter/material.dart';

class ReportDialog extends StatelessWidget {
  final Function(String) onReportTypeSelected;

  ReportDialog({required this.onReportTypeSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selecciona el tipo de reporte'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.lightbulb),
            title: Text('mala iluminación'),
            onTap: () => onReportTypeSelected('mala iluminación'),
          ),
          ListTile(
            leading: Icon(Icons.warning),
            title: Text('inseguridad'),
            onTap: () => onReportTypeSelected('inseguridad'),
          ),
          ListTile(
            leading: Icon(Icons.directions_walk),
            title: Text('Interés peatonal'),
            onTap: () => onReportTypeSelected('interés peatonal'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
      ],
    );
  }
}
