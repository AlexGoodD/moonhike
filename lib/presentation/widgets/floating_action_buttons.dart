import 'package:flutter/material.dart';

class FloatingActionButtons extends StatelessWidget {
  final Future<void> Function() onStartRoute;
  final Future<void> Function() onCreateReport;
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
            onPressed: () async {
              await onStartRoute();
            },
            child: Icon(Icons.directions_walk),
            backgroundColor: Colors.blue,
          ),
        SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () async {
            await onCreateReport();
          },
          child: Icon(Icons.report),
          backgroundColor: Colors.red,
        ),
      ],
    );
  }
}
