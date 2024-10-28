// floating_action_buttons.dart

import 'package:flutter/material.dart';
import 'report_dialog.dart';

class FloatingActionButtons extends StatelessWidget {
  final VoidCallback onStartRoute;
  final Function(String, String) onCreateReport; // Cambiar tipo de función
  final bool showStartRouteButton;

  FloatingActionButtons({
    required this.onStartRoute,
    required this.onCreateReport,
    required this.showStartRouteButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showStartRouteButton)
          FloatingActionButton(
            onPressed: onStartRoute,
            child: Icon(Icons.directions_walk),
            backgroundColor: Colors.blue,
          ),
        SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ReportDialog(
                onReportSubmit: (reportType, note) {
                  onCreateReport(reportType, note);
                },
              ),
            );
          },
          child: Icon(Icons.report),
          backgroundColor: Colors.red,
        ),
      ],
    );
  }
}
