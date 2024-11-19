// Este archivo es la pantalla inicial que decide si se redirige al usuario a LoginPage o MapScreen.
import 'package:moonhike/imports.dart';
import 'package:url_launcher/url_launcher.dart';

class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return MapScreen();
        } else {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                color: paletteColors.firstColor,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(), // Empuja hacia abajo
                      Image.asset(
                        'assets/logo/Logo.png',
                        width: 400, // Ajusta el ancho del logo
                        height: 300, // Ajusta el alto del logo
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        width: 250, // Ancho específico para el título
                        child: Text(
                          'MoonHike',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 200, // Ancho específico para el texto de bienvenida
                        child: Text(
                          'Tu mejor compañero para esas caminatas nocturnas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: paletteColors.fourthColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      // Botón de Iniciar Sesión con degradado y borde
                      SizedBox(
                        width: 250, // Ancho común para los botones
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                paletteColors.topColor,
                                paletteColors.bottomColor,
                              ],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: paletteColors.borderColor),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Botón de Registro con borde sin relleno
                      SizedBox(
                        width: 250, // Ancho común para los botones
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: paletteColors.fourthColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'Registrarse',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Spacer(), // Empuja el enlace hacia abajo
                      // Texto que redirige a un sitio web
                      GestureDetector(
                        onTap: () {
                          const url = 'https://www.ejemplo.com';
                          launch(url);
                        },

                        child: SizedBox(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 40), // Espacio en l
                          child: Text(
                            'Calíficanos en la Play Store',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: paletteColors.fourthColor,
                              decoration: TextDecoration.underline,
                            )
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}