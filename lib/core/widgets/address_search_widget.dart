/*Este es el widget de la barra de búsqueda que usa la API de Google Places para autocompletar las
direcciones. Está en la capa de presentación, porque es un componente de interfaz de usuario.*/

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moonhike/imports.dart';

class AddressSearchWidget extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  AddressSearchWidget({required this.onLocationSelected});

  @override
  _AddressSearchWidgetState createState() => _AddressSearchWidgetState();
}

class _AddressSearchWidgetState extends State<AddressSearchWidget> {
  TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Obtener la posición actual del usuario
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _getSuggestions(String input) async {
    final String apiKey = ApiKeys.googleMapsApiKey;
    if (_currentPosition == null) return; // Asegúrate de que la ubicación esté disponible

    final String locationBias =
        '${_currentPosition!.latitude},${_currentPosition!.longitude}';
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input'
        '&locationbias=circle:5000@$locationBias&key=$apiKey';

    setState(() {
      _isLoading = true; // Muestra un indicador de carga mientras se obtienen los resultados
    });

    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);

    setState(() {
      _isLoading = false;
      _suggestions = json['predictions'];
    });
  }

  void _getLatLngFromPlaceId(String placeId) async {
    final String apiKey = ApiKeys.googleMapsApiKey;
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);
    var location = json['result']['geometry']['location'];
    LatLng selectedLocation = LatLng(location['lat'], location['lng']);

    widget.onLocationSelected(selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Caja de texto de búsqueda
        Material(
          elevation: 5.0,
          shadowColor: Colors.grey,
          borderRadius: BorderRadius.circular(10),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Buscar una dirección...',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  vertical: 15, horizontal: 20),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                _getSuggestions(value);
              } else {
                setState(() {
                  _suggestions = [];
                });
              }
            },
          ),
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        // Contenedor de sugerencias
        if (_suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: EdgeInsets.all(8),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Sombra hacia abajo
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_suggestions[index]['description']),
                  onTap: () {
                    String placeId = _suggestions[index]['place_id'];
                    _controller.text = _suggestions[index]['description'];
                    setState(() {
                      _suggestions = [];
                    });
                    _getLatLngFromPlaceId(placeId);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}