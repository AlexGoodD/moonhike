import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: Text('Selecciona el tipo de reporte'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.lightbulb),
            title: Text('Mala iluminación'),
            onTap: () => widget.onReportTypeSelected('Mala iluminación', note),
          ),
          ListTile(
            leading: Icon(Icons.warning),
            title: Text('Inseguridad'),
            onTap: () => widget.onReportTypeSelected('Inseguridad', note),
          ),
          ListTile(
            leading: Icon(Icons.directions_walk),
            title: Text('Interés peatonal'),
            onTap: () => widget.onReportTypeSelected('Poca vialidad peatonal', note),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Nota (opcional)'),
            onChanged: (value) {
              setState(() {
                note = value;
              });
            },
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
