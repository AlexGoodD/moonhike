import 'package:moonhike/imports.dart';

class FindLocationButton extends StatelessWidget {
  final Future<void> Function() onPressed;

  FindLocationButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: paletteColors.thirdColor, // Cambia el color según tu diseño
      child: Icon(
        Icons.my_location,
        color: paletteColors.fourthColor,
      ),
    );
  }
}