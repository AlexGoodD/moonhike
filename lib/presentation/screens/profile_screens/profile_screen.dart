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
  final UserService userService = UserService(); // Instancia de UserService

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

  Future<void> _logout() async {
    try {
      await userService.logout(context); // Llama al método logout de UserService

      // Redirige al LoginPage y elimina todas las pantallas anteriores de la pila
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carga mientras se obtienen los datos
          : userData == null
          ? Center(child: Text('No se encontraron datos del usuario.'))
          : Container(
        width: double.infinity, // Asegura que ocupe todo el ancho de la pantalla
        height: double.infinity, // Asegura que ocupe todo el alto de la pantalla
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundTop,
              AppColors.backgroundBottom,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Barra superior con título y botón de logout
              Padding(
                padding: EdgeInsets.only(top: 30.0), // Ajusta el valor según la separación deseada
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.white), // Color del ícono de logout
                      onPressed: _logout, // Llama a _logout en lugar de signOut directo
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0), // Espacio entre la barra superior y el contenido
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 60), // Espacio para la imagen sobresaliente
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.profileCard, // Fondo del rectángulo
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 50), // Espacio para la imagen de perfil
                        Text(
                          userData?['name'] ?? 'Nombre del Usuario',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: const Color.fromARGB(255, 255, 255, 255), // Color de texto principal
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          userData?['email'] ?? 'correo@ejemplo.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: paletteColors.fourthColor, // Color de texto secundario
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Actividad',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(82, 235, 223, 255), // Color de "Actividad"
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActivityCard(Icons.location_on, 'Reportes a la comunidad', '13', isReports: true),
                            _buildActivityCard(Icons.nights_stay, 'Días activo en MoonHike', '125', isReports: false),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -10,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color.fromARGB(255, 132, 149, 233),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: NetworkImage(
                          user?.photoURL ?? 'https://via.placeholder.com/150',
                        ),
                      ),
                    ),
                  ),
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
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }


  Widget _buildActivityCard(IconData icon, String label, String count, {required bool isReports}) {
    return Container(
      width: 150.0, // Ajustar el ancho de la tarjeta
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isReports
              ? [Colors.black, AppColors.activityReports] // Degradado para "Reportes"
              : [AppColors.activityDaysTop, AppColors.activityDaysBottom], // Degradado para "Días activos"
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Justificar el texto a la izquierda
        mainAxisSize: MainAxisSize.min, // Ajusta el tamaño de la tarjeta al contenido
        children: [
          // Título en la parte superior izquierda
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(176, 227, 217, 255), // Color de texto claro para contraste
            ),
          ),
          SizedBox(height: 8.0),
          // Número y icono en la parte inferior derecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(), // Empuja el número e ícono a la derecha
              Icon(icon, size: 24, color: AppColors.buttonIcon),
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Método para crear los botones de configuración
  Widget _buildSettingsButton(BuildContext context,
      {required IconData icon, required String title, required String subtitle}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0), // Espacio entre las cards
      decoration: BoxDecoration(
        color: AppColors.generalCard, // Color de fondo de las cards
        borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
      ),
      child: ListTile(
        leading: Container(
          width: 53.0, // Ancho del fondo blanco
          height: 53.0, // Alto del fondo blanco
          decoration: BoxDecoration(
            color: Colors.white, // Fondo blanco para el ícono
            borderRadius: BorderRadius.circular(8.0), // Bordes redondeados del fondo del ícono
          ),
          padding: EdgeInsets.all(4.0), // Espaciado interno para el ícono
          child: Icon(icon, color: AppColors.buttonIcon, size: 32.0),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.white), // Asegura que el texto sea visible
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: const Color.fromARGB(139, 255, 255, 255)), // Color de texto secundario
        ),
      ),
    );
  }
}
