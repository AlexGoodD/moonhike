import 'package:flutter/material.dart';
import 'package:moonhike/imports.dart';

class FloatingActionButtons extends StatelessWidget {
  final Future<void> Function() onStartRoute;
  final Future<void> Function() onCreateReport;
  final VoidCallback onPreviousRoute; // Callback para mostrar la ruta anterior
  final VoidCallback onNextRoute; // Callback para mostrar la siguiente ruta
  final bool showStartRouteButton;

  FloatingActionButtons({
    required this.onStartRoute,
    required this.onCreateReport,
    required this.showStartRouteButton,
    required this.onNextRoute,
    required this.onPreviousRoute,
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
          SizedBox(height: 10),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    FloatingActionButton(
    onPressed: onPreviousRoute,
    child: Icon(Icons.arrow_back),
    backgroundColor: Colors.grey,
    heroTag: 'previousRoute',
    ),
    SizedBox(width: 10),
    FloatingActionButton(
    onPressed: onNextRoute,
    child: Icon(Icons.arrow_forward),
    backgroundColor: Colors.grey,
    heroTag: 'nextRoute',
    ),
      ],
    ),
    ],
    );
  }
}
