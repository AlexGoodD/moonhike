import 'package:flutter/material.dart';
import 'package:moonhike/core/constans/colors.dart';

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
        GestureDetector(
          onTap: showPreviousRoute,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: paletteColors.fourthColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              size: 30,
              color: paletteColors.secondColor,
            ),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: showNextRoute,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: paletteColors.fourthColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_forward,
              size: 30,
              color: paletteColors.secondColor,
            ),
          ),
        ),
      ],
    );
  }
}