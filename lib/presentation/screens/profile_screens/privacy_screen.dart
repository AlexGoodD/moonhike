import 'package:moonhike/imports.dart';

class PrivacyScreen extends StatefulWidget {
  @override
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      // Validación: campos vacíos
      if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, completa todos los campos')),
        );
        return;
      }

      // Validación: contraseñas no coinciden
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      try {
        User? user = FirebaseAuth.instance.currentUser;

        // Credenciales para la reautenticación
        final credential = EmailAuthProvider.credential(
          email: user?.email ?? '',
          password: currentPassword,
        );

        // Reautenticación
        await user?.reauthenticateWithCredential(credential);

        // Actualización de la contraseña
        await user?.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contraseña actualizada correctamente')),
        );

        // Limpiar los campos del formulario
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } catch (e) {
        // Validación: contraseña actual incorrecta
        if (e is FirebaseAuthException && e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('La contraseña actual es incorrecta')),
          );
        } else {
          // Otros errores
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cambiar la contraseña: $e')),
          );
        }
      }
    } else {
      // Validación: formulario inválido
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, verifica los datos ingresados')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity, // Extiende el contenedor hasta el final de la pantalla
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ProfileColors.backgroundTop, ProfileColors.backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Privacidad',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Icon(Boxicons.bx_key, color: Colors.white, size: 28),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Cambia tu contraseña',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildPasswordField(_currentPasswordController, 'Contraseña actual'),
                  SizedBox(height: 15),
                  _buildPasswordField(_newPasswordController, 'Nueva contraseña'),
                  SizedBox(height: 15),
                  _buildPasswordField(_confirmPasswordController, 'Confirma tu nueva contraseña'),
                  SizedBox(height: 30),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Color.fromARGB(140, 15, 11, 32),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color.fromARGB(255, 86, 81, 249)),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 250, // Ancho del botón
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(122, 88, 247, 1), Color.fromRGBO(95, 60, 229, 1)], // Colores del gradiente
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: SizedBox(height: 55), // Altura del botón
          ),
          Positioned.fill(
            child: ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Guardar cambios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
