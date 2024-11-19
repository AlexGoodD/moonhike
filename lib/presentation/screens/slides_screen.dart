import 'package:moonhike/imports.dart';

class SlidesScreen extends StatefulWidget {
  @override
  _SlidesScreenState createState() => _SlidesScreenState();
}

class _SlidesScreenState extends State<SlidesScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          _buildSlide(
            context,
            title: '¡Bienvenido a MoonHike!',
            description:
                'Descubre la manera más segura de caminar por la ciudad. MoonHike te ayuda a planear rutas que priorizan tu seguridad y bienestar.',
            imagePath: 'assets/slides/slide1.png',
            isLastSlide: false,
            titleColor: const Color.fromARGB(255, 106, 92, 196), // Color del título
          ),
          _buildSlide(
            context,
            title: 'Seguridad en tu Ruta',
            description:
                'Usamos datos en tiempo real sobre incidentes y reportes comunitarios para sugerirte las mejores rutas, evitando zonas peligrosas o poco iluminadas.',
            imagePath: 'assets/slides/slide2.png',
            isLastSlide: false,
            titleColor: const Color.fromARGB(255, 116, 205, 154), // Color del título
          ),
          _buildSlide(
            context,
            title: 'Reportes comunitarios',
            description:
                'Con MoonHike, puedes reportar zonas inseguras o condiciones de iluminación deficientes y ayudar a otros a mantenerse informados.',
            imagePath: 'assets/slides/slide3.png',
            isLastSlide: false,
            titleColor: const Color.fromARGB(255, 237, 193, 128), // Color del título
          ),
          _buildSlide(
            context,
            title: '¡Mantente activo y comparte!',
            description:
                'Comparte la app con tus amigos para que también disfruten de caminatas nocturnas seguras.',
            imagePath: 'assets/slides/slide4.png',
            isLastSlide: true,
            titleColor: const Color.fromARGB(255, 80, 77, 216), // Color del título
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(
    BuildContext context, {
    required String title,
    required String description,
    required String imagePath,
    required bool isLastSlide,
    required Color titleColor,
  }) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 0, 0, 0), const Color.fromARGB(255, 30, 8, 75)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: titleColor, // Color dinámico del título
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    SizedBox(height: 40),
                    Center(
                      child: Image.asset(
                        imagePath,
                        width: 270,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 39, 34, 75), // Fondo grisáceo
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(context, isLastSlide ? 'Comenzar' : 'Siguiente', isLastSlide),
                SizedBox(height: 10),
                _buildIndicator(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String text, bool isLastSlide) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromRGBO(122, 88, 247, 1), Color.fromRGBO(95, 60, 229, 1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: () async {
          if (isLastSlide) {
          // Guardar en SharedPreferences que las diapositivas ya fueron vistas
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('slidesSeen', true);

          // Redirigir a MapScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
        } else {
          _pageController.nextPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        },
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color.fromARGB(255, 89, 69, 169)
                : const Color.fromARGB(34, 255, 255, 255),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
