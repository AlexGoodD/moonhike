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
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  LatLng? _currentPosition;
  final DirectionsService _directionsService = DirectionsService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
    if (input.isEmpty) return;

    final String apiKey = ApiKeys.googleMapsApiKey;
    if (_currentPosition == null) return;

    final String locationBias =
        '${_currentPosition!.latitude},${_currentPosition!.longitude}';
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input'
        '&locationbias=circle:5000@$locationBias&key=$apiKey';

    setState(() {
      _isLoading = true;
    });

    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);

    if (_controller.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _suggestions = [];
      });
      return;
    }

    List<Map<String, dynamic>> suggestions = [];
    for (var suggestion in json['predictions']) {
      var placeId = suggestion['place_id'];
      var shortName = suggestion['structured_formatting']['main_text'];
      var address = suggestion['structured_formatting']['secondary_text'];

      LatLng? suggestionLocation = await _getLatLngFromPlaceId(placeId);
      if (suggestionLocation != null) {
        var routeInfo = await _directionsService.getRouteInfo(_currentPosition!, suggestionLocation);

        suggestions.add({
          'placeId': placeId,
          'shortName': shortName,
          'address': address,
          'distance': routeInfo?['distance'] ?? 'N/A',
          'duration': routeInfo?['duration'] ?? 'N/A',
          'description': suggestion['description'],
          'location': suggestionLocation, // Store the location directly here
        });
      }
    }

    if (_controller.text.isNotEmpty) {
      setState(() {
        _isLoading = false;
        _suggestions = suggestions;
      });
    } else {
      setState(() {
        _isLoading = false;
        _suggestions = [];
      });
    }
  }

  Future<LatLng?> _getLatLngFromPlaceId(String placeId) async {
    final String apiKey = ApiKeys.googleMapsApiKey;
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);
    if (json['status'] == 'OK') {
      var location = json['result']['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    }
    return null;
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _suggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda con botón "x"
        Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: _controller,
                style: TextStyle(color: AddressSearchColors.suggestionColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AddressSearchColors.backgroundColor,
                  hintText: '¿Adónde vamos?',
                  hintStyle: TextStyle(color: AddressSearchColors.labelColor),
                  prefixIcon: Icon(Icons.search, color: AddressSearchColors.labelColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.only(left: 20, right: 45, top: 15, bottom: 15), //Evita que sobrepase al botón de "x"
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
              // Botón "x" para limpiar el texto
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, color: AddressSearchColors.labelColor),
                  onPressed: _clearSearch,
                ),
            ],
          ),
        ),
        /*
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),*/
        if (_suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            padding: EdgeInsets.all(0),
            height: 350,
            decoration: BoxDecoration(
              color: AddressSearchColors.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                var suggestion = _suggestions[index];
                return ListTile(
                  title: Text(suggestion['shortName'],
                      style: TextStyle(color: AddressSearchColors.suggestionColor, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(suggestion['address'], style: TextStyle(color: AddressSearchColors.suggestionColor)),
                      Text('${suggestion['distance']}', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  onTap: () async {
                    _controller.text = suggestion['description'];
                    setState(() {
                      _suggestions = [];
                    });
                    widget.onLocationSelected(suggestion['location']); // Pass the stored location directly
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}