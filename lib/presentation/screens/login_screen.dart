//Este archivo contiene la pantalla de login
import 'package:moonhike/imports.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userUID = prefs.getString('userUID');

    if (userUID != null) {
      // Si ya hay una sesión activa, redirige a MapScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MapScreen()), // Pantalla principal
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Guardar UID en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userUID', userCredential.user!.uid);

      // Verificar si el usuario ya ha visto las slides
      bool hasSeenSlides = prefs.getBool('hasSeenSlides') ?? false;

      if (!hasSeenSlides) {
        // Si no ha visto las slides, redirigir a SlidesScreen y actualizar la preferencia
        await prefs.setBool('hasSeenSlides', true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SlidesScreen()),
        );
      } else {
        // Si ya ha visto las slides, redirigir directamente al MapScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "Error desconocido";
      });
      print('Error de autenticación: $e'); // Agrega esta línea para más detalles
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""), // Título vacío
        backgroundColor: Colors.transparent, // Fondo transparente del AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Cambia el color del botón de regreso
          onPressed: () => Navigator.of(context).pop(), // Acción al presionar el botón de regreso
        ),
        elevation: 0, // Elimina la sombra del AppBar
      ),
      backgroundColor: paletteColors.firstColor, // Color de fondo rojo
      resizeToAvoidBottomInset: true,
      // Ajusta la pantalla al aparecer el teclado
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          // Estira los widgets horizontalmente
          children: [
            SizedBox(height: 25), // Espacio superior
            Align(
              alignment: Alignment.centerLeft, // Alinea el texto a la izquierda
              child: Text(
                'Inicio de sesión',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                labelStyle: TextStyle(color: paletteColors.fourthColor),
                // Cambia el color del texto del label
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: paletteColors.sevenColor),
                  // Borde normal
                  borderRadius: BorderRadius.circular(15), // Bordes redondeados
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: paletteColors.sevenColor),
                  // Borde al enfocarse
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              style: TextStyle(color: Colors.white), // Color del texto dentro del campo
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: paletteColors.fourthColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: paletteColors.sevenColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: paletteColors.sevenColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: paletteColors.fourthColor,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              style: TextStyle(color: Colors.white), // Color del texto dentro del campo
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 250, // Ancho común para los botones
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [paletteColors.topColor, paletteColors.bottomColor],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: OutlinedButton(
                  onPressed: () {
                    _login();
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    side: BorderSide(color: Colors.transparent), // Elimina el borde del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
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

            SizedBox(height: 10),
            if (_errorMessage
                .isNotEmpty) // Mostrar mensaje de error solo si hay alguno
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}