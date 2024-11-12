import 'package:flutter/material.dart';

class SelectRouteWidget extends StatelessWidget {
  final VoidCallback showPreviousRoute;
  final VoidCallback showNextRoute;

  SelectRouteWidget({
    required this.showPreviousRoute,
    required this.showNextRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: showPreviousRoute,
          child: Icon(Icons.arrow_back),
          backgroundColor: Colors.grey,
          heroTag: 'previousRoute',
        ),
        SizedBox(width: 10),
        FloatingActionButton(
          onPressed: showNextRoute,
          child: Icon(Icons.arrow_forward),
          backgroundColor: Colors.grey,
          heroTag: 'nextRoute',
        ),
      ],
    );
  }
}