import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _pickedLocation;
  LatLng _defaultLocation = LatLng(13.0827, 80.2707); // Default: Chennai
  List<dynamic> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final position =
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final currentLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _defaultLocation = currentLatLng;
        _pickedLocation = currentLatLng;
      });
      _mapController.move(currentLatLng, 16);
    }
  }

  Future<void> _searchPlace(String query) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5");
    final response = await http.get(url, headers: {
      "User-Agent": "FlutterApp (your@email.com)"
    });

    if (response.statusCode == 200) {
      setState(() {
        _suggestions = json.decode(response.body);
      });
    }
  }

  Future<void> _searchWithButton() async {
    if (_searchController.text.isEmpty) return;

    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=${_searchController.text}&format=json&limit=1");
    final response = await http.get(url, headers: {
      "User-Agent": "FlutterApp (contact@email.com)"
    });

    final data = json.decode(response.body);
    if (data.isNotEmpty) {
      final place = data.first;
      _selectPlace(place);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Place not found.")),
      );
    }
  }

  void _selectPlace(dynamic place) {
    final lat = double.parse(place['lat']);
    final lon = double.parse(place['lon']);
    final latLng = LatLng(lat, lon);

    _mapController.move(latLng, 16);
    setState(() {
      _pickedLocation = latLng;
      _searchController.text = place['display_name'];
      _suggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick a Location")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultLocation,
              initialZoom: 13,
              onTap: (tapPos, latlng) {
                setState(() => _pickedLocation = latlng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              if (_pickedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: _pickedLocation!,
                      child: const Icon(
                        Icons.location_pin,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),


          // 🔍 Search field and search button
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(8),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            if (val.length > 2) _searchPlace(val);
                          },
                          decoration: InputDecoration(
                            hintText: "Search a place",
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _suggestions = []);
                              },
                            )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searchWithButton,
                      child: const Text("Search"),
                    ),
                  ],
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5)
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(suggestion['display_name']),
                          onTap: () => _selectPlace(suggestion),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ✅ Confirm button
          if (_pickedLocation != null)
            Positioned(
              bottom: 30,
              left: 50,
              right: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Confirm Location"),
                onPressed: () => Navigator.pop(context, _pickedLocation),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
