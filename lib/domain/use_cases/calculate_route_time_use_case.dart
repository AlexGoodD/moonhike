class CalculateRouteTimeUseCase {
  final double walkingSpeed = 1.4; // Velocidad promedio en metros por segundo (5 km/h)

  // Devuelve el tiempo estimado en minutos
  int execute(double distanceInMeters) {
    double timeInSeconds = distanceInMeters / walkingSpeed;
    return (timeInSeconds / 60).round(); // Convierte a minutos y redondea
  }
}