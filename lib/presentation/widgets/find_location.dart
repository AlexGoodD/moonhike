import 'package:moonhike/imports.dart';

class FindLocationButton extends StatelessWidget {
  final Future<void> Function() onPressed;

  FindLocationButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 86, 86, 174), const Color.fromARGB(255, 53, 36, 140)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent, // Fondo transparente para mostrar el degradado
        elevation: 0, // Eliminar la sombra para un efecto más limpio
        child: Icon(
          Icons.my_location,
          size: 30.0, // Tamaño del icono
          color: Colors.white,
        ),
      ),
    );
  }
}