import 'package:moonhike/imports.dart';

class SlidesScreen extends StatefulWidget {
  const SlidesScreen({super.key});

  @override
  State<SlidesScreen> createState() => _SlidesScreenState();
}

class _SlidesScreenState extends State<SlidesScreen> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  final List<Widget> _slides = const [
    Slide1(),
    Slide2(),
    Slide3(),
    Slide4(),
  ];

  void _nextSlide() {
    if (_currentSlide < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MapScreen()),
      );
    }
  }

  void _goToSlide(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView para animación fluida
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) => _slides[index],
          ),
          // Botones y navegación
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Botones de navegación
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botón "Saltar"
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          _slides.length - 1, // Ir directamente a la última diapositiva
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        print("Saltar a la última diapositiva");
                      },
                      child: const Text(
                        "Saltar",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    // Botón de "Siguiente" como ícono
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentFont_5, // Color de fondo del círculo
                      ),
                      child: IconButton(
                        onPressed: _nextSlide,
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        iconSize: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Indicadores de página (bolitas)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    return GestureDetector(
                      onTap: () => _goToSlide(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentSlide == index
                                ? paletteColors.borderColor
                                : paletteColors.fifthColor,
                            width: 3,
                          ),
                          shape: BoxShape.circle,
                          color: _currentSlide == index
                              ? paletteColors.borderColor
                              : Colors.transparent,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}