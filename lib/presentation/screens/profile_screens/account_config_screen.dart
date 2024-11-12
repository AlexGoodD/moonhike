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
      appBar: AppBar(
        title: Text('Configuración de cuenta'),
        backgroundColor: paletteColors.firstColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              paletteColors.firstColor, // Reemplaza con el color de inicio del gradiente
              paletteColors.secondColor,  // Reemplaza con el color final del gradiente
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona tu avatar:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: 4, // Número de avatares
                itemBuilder: (context, index) {
                  final avatarPath = 'assets/avatars/avatar${index + 1}.png';
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAvatar = avatarPath;
                      });
                      _updateAvatarInFirestore(avatarPath);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedAvatar == avatarPath ? Colors.blueAccent : Colors.grey.shade300,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(avatarPath, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildTextField(_nameController, 'Nombre', Icons.person),
              SizedBox(height: 15),
              _buildTextField(_emailController, 'Correo electrónico', Icons.email),
              SizedBox(height: 15),
              _buildTextField(_phoneController, 'Teléfono', Icons.phone),
              SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: _updateUserData,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Guardar cambios',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

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
  }

  Future<void> _updateUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
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
