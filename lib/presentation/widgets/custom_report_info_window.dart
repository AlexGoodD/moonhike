import 'package:flutter/material.dart';

class CustomReportInfoWindow extends StatelessWidget {
  final String reportType;
  final String createdBy;
  final String date;
  final String time;

  const CustomReportInfoWindow({
    Key? key,
    required this.reportType,
    required this.createdBy,
    required this.date,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(reportType, style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Creado por: $createdBy', style: TextStyle(fontSize: 14)),
          SizedBox(height: 8),
          Text('Fecha: $date', style: TextStyle(fontSize: 14)),
          Text('Hora: $time', style: TextStyle(fontSize: 14)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cerrar'),
        ),
      ],
    );
  }
}
