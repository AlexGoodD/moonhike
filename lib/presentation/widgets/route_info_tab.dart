import 'package:flutter/material.dart';

class RouteInfoTab extends StatelessWidget {
  final String? duration;
  final String? distance;
  final VoidCallback onClose;
  final ScrollController scrollController;

  RouteInfoTab({
    this.duration,
    this.distance,
    required this.onClose,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de arrastre y botón de cerrar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: onClose,
              ),
            ],
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.all(16),
              children: [
                if (duration != null && distance != null) ...[
                  Text(
                    'Duración estimada: $duration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Distancia: $distance',
                    style: TextStyle(fontSize: 14),
                  ),
                ] else
                  Text(
                    'Cargando información...',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}