import 'package:moonhike/imports.dart';

class AccountConfigScreen extends StatefulWidget {
  @override
  _AccountConfigScreenState createState() => _AccountConfigScreenState();
}

class _AccountConfigScreenState extends State<AccountConfigScreen> {
  String? selectedAvatar;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['name'] ?? '';
          _emailController.text = userDoc['email'] ?? '';
          _phoneController.text = userDoc['phone'] ?? '';
          selectedAvatar = userDoc['profile_image'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ProfileColors.backgroundTop, ProfileColors.backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Centrar el contenido
            children: [
              // Flecha para volver atrás y título
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Configuración de cuenta',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildAvatarSelection(),
              SizedBox(height: 20),
              _buildTextField(_nameController, 'Nombre', Boxicons.bx_user),
              SizedBox(height: 15),
              _buildTextField(_emailController, 'Correo electrónico', Boxicons.bx_envelope),
              SizedBox(height: 15),
              _buildTextField(_phoneController, 'Teléfono', Boxicons.bx_phone),
              SizedBox(height: 25),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 250,
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
                        onPressed: _updateUserData,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelection() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.83, // Ajusta el ancho para centrar mejor
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: ProfileColors.profileCard, // Fondo sutil del rectángulo general
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centrar el texto
          children: [
            Text(
              'Selecciona tu avatar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              textAlign: TextAlign.center, // Centrar el texto
            ),
            SizedBox(height: 0), // Reducir el espacio entre el texto y la cuadrícula
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10, // Reducir el espacio entre columnas
                mainAxisSpacing: 10, // Reducir el espacio entre filas
              ),
              itemCount: 4, // Número de avatares
              itemBuilder: (context, index) {
                final avatarPath = 'assets/avatars/avatar${index + 1}.png';
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAvatar = avatarPath;
                    });
                    //_updateAvatarInFirestore(avatarPath);
                  },
                  child: Container(
                    height: 70, // Tamaño más pequeño para los rectángulos
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.black87, const Color.fromARGB(136, 25, 15, 73)], // Gradiente oscuro
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: selectedAvatar == avatarPath ? const Color.fromARGB(255, 86, 81, 249) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(avatarPath, fit: BoxFit.contain),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color.fromARGB(173, 255, 255, 255), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
        filled: true,
        fillColor: Color.fromARGB(140, 15, 11, 32), // Color de fondo más oscuro
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Esquinas más redondeadas
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
      style: TextStyle(color: const Color.fromARGB(110, 255, 255, 255)),
    );
  }

  /*Evitar saturación de notificaciones al cambiar de avatar
  Future<void> _updateAvatarInFirestore(String avatarPath) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'profile_image': avatarPath,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avatar actualizado correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el avatar: $e')),
      );
    }
  }*/

  Future<void> _updateUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'profile_image': selectedAvatar, // Actualiza el avatar junto con los otros datos
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datos actualizados correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar los datos: $e')),
      );
    }
  }
}
