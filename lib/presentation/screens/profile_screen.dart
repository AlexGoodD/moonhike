import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moonhike/imports.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser; // Usuario autenticado
  int _selectedIndex = 3; // Índice de la pantalla actual (Perfil)
  Map<String, dynamic>? userData; // Variable para almacenar los datos del usuario de Firestore
  bool isLoading = true; // Bandera para controlar la carga

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Llama a la función para obtener los datos de Firestore
  }

  Future<void> _fetchUserData() async {
    try {
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists) {
          print("Datos del usuario obtenidos: ${userDoc.data()}"); // Depuración
          if (mounted) {
            setState(() {
              userData = userDoc.data() as Map<String, dynamic>?;
              isLoading = false; // Termina la carga cuando los datos se obtienen
            });
          }
        } else {
          print("Documento del usuario no encontrado."); // Depuración
          if (mounted) {
            setState(() {
              isLoading = false;
              userData = {
                'name': 'Nombre no disponible',
                'email': user!.email ?? 'Correo no disponible',
                'phone': 'Número no disponible'
              };
            });
          }
        }
      }
    } catch (e) {
      print("Error al obtener los datos de Firestore: $e"); // Depuración
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos del usuario: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navegación a la página correspondiente
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReportsScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        break;
      case 3:
        // Ya estás en la pantalla de perfil
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login'); // Redirige a la página de login
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Muestra un indicador de carga mientras se obtienen los datos
          : userData == null
              ? Center(child: Text('No se encontraron datos del usuario.'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Foto de perfil y nombre
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50.0,
                                backgroundImage: NetworkImage(
                                    user?.photoURL ?? 'https://via.placeholder.com/150'), // Placeholder si no hay foto
                              ),
                              SizedBox(height: 10),
                              Text(
                                userData?['name'] ?? 'Nombre del Usuario',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userData?['email'] ?? 'correo@ejemplo.com',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Contadores de actividad
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActivityCard(Icons.location_on, 'Reportes', '13'),
                          _buildActivityCard(Icons.nights_stay, 'Días activos', '125'),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Botones de configuración
                      _buildSettingsButton(
                        context,
                        icon: Icons.settings,
                        title: 'Configuración de cuenta',
                        subtitle: 'Actualiza y edita tu información personal',
                      ),
                      _buildSettingsButton(
                        context,
                        icon: Icons.lock,
                        title: 'Privacidad',
                        subtitle: 'Cambia tu contraseña',
                      ),
                      _buildSettingsButton(
                        context,
                        icon: Icons.share,
                        title: 'Invita a un amigo/a',
                        subtitle: 'Comparte la experiencia MoonHike!',
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Método para crear las cartas de actividad
  Widget _buildActivityCard(IconData icon, String label, String count) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: 120.0,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.purple),
            SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              count,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Método para crear los botones de configuración
  Widget _buildSettingsButton(BuildContext context,
      {required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Acción cuando se presiona el botón
      },
    );
  }
}
