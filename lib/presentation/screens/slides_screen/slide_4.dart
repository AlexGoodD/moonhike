import 'package:moonhike/imports.dart';

class Slide4 extends StatelessWidget {
  const Slide4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.topColor, AppColors.bottomColor],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 580, // Mueve el rectángulo hacia abajo
              child: Transform.rotate(
                angle: 3, // Ángulo de rotación en radianes
                child: Container(
                  width: 1000,
                  height: 500,
                  decoration: BoxDecoration(
                    color: AppColors.floor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            // Contenido principal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 40,
                  ),
                  child: Text(
                    "¡Mantente activo y comparte!",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentFont_2,
                    ),
                  ),
                ),
                // Subtítulo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        const TextSpan(
                          text: "Comparte la app con tus amigos para que también disfruten de caminatas nocturnas seguras.",
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Imagen
                Center(
                  child: Image.asset(
                    "assets/decoration/Share.png",
                    fit: BoxFit.contain,
                    height: 260,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}