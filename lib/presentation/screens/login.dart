//Este archivo contiene la pantalla de login

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moonhike/presentation/screens/home.dart'; // Asegúrate de que este es el archivo correcto
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart'; // Tu archivo de registro
import 'package:moonhike/core/constans/colors.dart'; // Asegúrate de que esto está correcto

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

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
        MaterialPageRoute(builder: (context) => MapScreen()), // Pantalla principal
      );
    }
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

      // Redirigir a la pantalla principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MapScreen()),
      );
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
      appBar: AppBar(title: Text("")),
      resizeToAvoidBottomInset: true, // Ajusta la pantalla al aparecer el teclado
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los widgets horizontalmente
          children: [
            SizedBox(height: 40), // Espacio superior
            Text(
              "Ingresa a tu cuenta",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50, // Tamaño del logo
              backgroundColor: Colors.grey[300], // Color de fondo gris para indicar espacio del logo
              child: Icon(Icons.person, size: 50, color: Colors.grey), // Icono temporal
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appColor, // Cambiado a backgroundColor
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Iniciar Sesión", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 10),
            if (_errorMessage.isNotEmpty) // Mostrar mensaje de error solo si hay alguno
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("¿No tienes una cuenta? "),
                TextButton(
                  onPressed: () {
                    // Redirige al registro si no tiene cuenta
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text("Regístrate"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}