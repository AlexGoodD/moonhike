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

  int reportCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadUserReportCount(); // Llama a la función para obtener los datos de Firestore
  }

  Future<void> _loadUserReportCount() async {
    int count = await _getUserReportCount();
    if (mounted) {
      setState(() {
        reportCount = count;
      });
    }
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

  Future<int> _getUserReportCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    QuerySnapshot reportSnapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('user', isEqualTo: user.email)
        .get();

    return reportSnapshot.size; // Devuelve el número de reportes
  }

  Future<void> _logout() async {
    try {
      await userService.logout(context); // Llama al método logout de UserService

      // Redirige al LoginPage y elimina todas las pantallas anteriores de la pila
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => InitialScreen()),
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
                        ProfileColors.backgroundTop,
                        ProfileColors.backgroundBottom,
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
                          padding: EdgeInsets.only(top: 31.0), // Ajusta el valor según la separación deseada
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.logout, color: Colors.white), // Color del ícono de logout
                                onPressed: _logout,
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
                                color: ProfileColors.profileCard, // Fondo del rectángulo
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center, // Centra el contenido horizontalmente
                                children: [
                                  SizedBox(height: 50), // Espacio para la imagen de perfil
                                  Text(
                                    userData?['name'] ?? 'Nombre del Usuario',
                                    textAlign: TextAlign.center, // Centra el texto
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
                                      _buildActivityCard(
                                        Icons.location_on,
                                        'Reportes a la comunidad',
                                        '$reportCount', // Muestra el número de reportes reales
                                        isReports: true,
                                        iconColor: const Color.fromARGB(255, 235, 95, 85), // Color personalizado para el ícono de reportes
                                      ),
                                      // Reemplaza la card de días activo con el nuevo widget
                                      buildDaysActiveCard(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: -10,
                              child: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser?.uid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircleAvatar(
                                      radius: 60,
                                      backgroundColor: const Color.fromARGB(255, 132, 149, 233),
                                      child: CircleAvatar(
                                        radius: 56,
                                        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
                                        child: CircularProgressIndicator(), // Indicador de carga
                                      ),
                                    );
                                  }

                                  if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                                    return CircleAvatar(
                                      radius: 60,
                                      backgroundColor: const Color.fromARGB(255, 132, 149, 233),
                                      child: CircleAvatar(
                                        radius: 56,
                                        backgroundImage: NetworkImage(
                                          user?.photoURL ?? 'https://picsum.photos/219/202',
                                        ),
                                      ),
                                    );
                                  }

                                  final userData = snapshot.data!.data() as Map<String, dynamic>?;
                                  final profileImage = userData?['profile_image'];

                                  return CircleAvatar(
                                    radius: 60,
                                    backgroundColor: const Color.fromARGB(255, 132, 149, 233),
                                    child: CircleAvatar(
                                      radius: 56,
                                      backgroundImage: profileImage != null
                                          ? AssetImage(profileImage) // Usa la imagen de los assets si existe
                                          : NetworkImage(
                                              user?.photoURL ?? 'https://picsum.photos/219/202',
                                            ) as ImageProvider, // URL predeterminada
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Botones de configuración
                        _buildSettingsButton(
                          context,
                          icon: Boxicons.bxs_cog,
                          title: 'Configuración de cuenta',
                          subtitle: 'Actualiza y edita tu información personal',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AccountConfigScreen()), // Reemplaza con tu widget de pantalla de configuración
                            ).then((_) {
                              // Refresca los datos cuando regresas a ProfileScreen
                              _fetchUserData();
                            });
                          },
                        ),
                        _buildSettingsButton(
                          context,
                          icon: Boxicons.bxs_lock_open_alt,
                          title: 'Privacidad',
                          subtitle: 'Cambia tu contraseña',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PrivacyScreen()), // Reemplaza con tu widget de pantalla de privacidad
                            );
                          },
                        ),
                        _buildSettingsButton(
                          context,
                          icon: Boxicons.bxs_paper_plane,
                          title: 'Invita a un amigo/a',
                          subtitle: 'Comparte la experiencia MoonHike!',
                          onTap: () {
                            InviteFriendBottomSheet.show(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 3, // Índice actual para la pantalla de Configuración
        onTap: (index) {}, // No necesitas ninguna lógica extra aquí
      ),
    );
  }


 Widget _buildActivityCard(IconData icon, String label, String count, {required bool isReports, required Color iconColor}) {
    return Container(
      width: 150.0, // Ajustar el ancho de la tarjeta
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isReports
              ? [Colors.black, ProfileColors.activityReports] // Degradado para "Reportes"
              : [ProfileColors.activityDaysTop, ProfileColors.activityDaysBottom], // Degradado para "Días activos"
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
              color: Colors.white, // Color de texto claro para contraste
            ),
          ),
          SizedBox(height: 8.0),
          // Número y icono en la parte inferior derecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(), // Empuja el número e ícono a la derecha
              Icon(icon, size: 24, color: iconColor), // Usa el color pasado como parámetro
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

  Widget buildDaysActiveCard() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        String daysCount = '0'; // Valor predeterminado

        if (snapshot.connectionState == ConnectionState.waiting) {
          daysCount = '...'; // Indicador de carga mientras se obtienen los datos
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            daysCount = 'N/A'; // Muestra "N/A" si hay error o no hay datos
          } else {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final Timestamp? createdAt = userData?['createdAt'];

            if (createdAt != null) {
              final DateTime creationDate = createdAt.toDate();
              daysCount = DateTime.now().difference(creationDate).inDays.toString();
            }
          }
        }

        return Container(
          width: 150.0, // Ajustar el ancho de la tarjeta
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ProfileColors.activityDaysTop, ProfileColors.activityDaysBottom], // Degradado para "Días activos"
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Justificar el texto a la izquierda
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño de la tarjeta al contenido
            children: [
              // Título en la parte superior izquierda
              Text(
                'Días con MoonHike',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // Color de texto claro para contraste
                ),
              ),
              SizedBox(height: 8.0),
              // Número y icono en la parte inferior derecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(), // Empuja el número e ícono a la derecha
                  Icon(Boxicons.bxs_moon, size: 24, color: paletteColors.sixthColor), // Ícono de la card
                  Text(
                    " " + daysCount, // Muestra el número de días
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
      },
    );
  }

  // Método para crear los botones de configuración
  Widget _buildSettingsButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap, // Nuevo parámetro
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0), // Espacio entre las cards
      decoration: BoxDecoration(
        color: ProfileColors.generalCard, // Color de fondo de las cards
        borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.0), // Espacio interno alrededor del ícono
          decoration: BoxDecoration(
            color: Colors.white, // Color de fondo blanco
            shape: BoxShape.rectangle, // Forma de cuadrado
            borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
          ),
          child: Icon(icon, color: AppColors.buttonIcon),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.white), // Asegura que el texto sea visible
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[300]), // Color de texto secundario
        ),
        onTap: onTap, // Agregar funcionalidad al presionar
      ),
    );

  }
}