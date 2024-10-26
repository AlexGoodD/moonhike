//Este archivo contiene la pantalla de detalles del perfil
import 'package:moonhike/imports.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String originalName = 'Nombre del Usuario';
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    nameController.text = originalName;
    _getUserEmail(); // Llamamos al método para obtener el correo del usuario
  }

  // Método para obtener el correo del usuario y establecerlo en el controlador de email
  void _getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email;
      if (_userEmail != null) {
        emailController.text = _userEmail!; // Asigna el email del usuario al TextField
      }
    });
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Guardar cambios'),
          content: Text('¿Deseas guardar los cambios?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  originalName = nameController.text;
                  _userEmail = emailController.text;
                  isEditing = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancelar edición'),
          content: Text('¿Estás seguro de que deseas cancelar sin guardar los cambios?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  nameController.text = originalName;
                  emailController.text = _userEmail!;
                  isEditing = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 60.0,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            SizedBox(height: 20.0),
            isEditing ? _buildEditableFields() : _buildProfileDetails(),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (isEditing) {
                      _showSaveDialog();
                    } else {
                      setState(() {
                        isEditing = true;
                      });
                    }
                  },
                  icon: Icon(isEditing ? Icons.save : Icons.edit),
                  label: Text(isEditing ? 'Guardar cambios' : 'Editar perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (isEditing)
                  SizedBox(width: 10.0),
                if (isEditing)
                  ElevatedButton.icon(
                    onPressed: _showCancelDialog,
                    icon: Icon(Icons.cancel),
                    label: Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            if (!isEditing) ...[
              SizedBox(height: 20.0),
              ElevatedButton.icon(
                onPressed: () {
                  print('Cerrar sesión');
                },
                icon: Icon(Icons.logout),
                label: Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      children: [
        Text(
          nameController.text,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          emailController.text,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableFields() {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nombre',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10.0),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}