import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_place/google_place.dart';
import 'package:sample_proj/widgets/custom_bottom_nav.dart';
import 'package:sample_proj/widgets/glass_map_pin.dart'; // optional
import 'package:sample_proj/components/category_chips.dart';
import 'package:sample_proj/components/search_suggestion_overlay.dart';
import 'package:sample_proj/components/app_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _userLocation;
  int _selectedIndex = 0;
  int selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    "Food", "Fun", "History", "Hidden spots", "Art & Culture"
  ];

  final List<LatLng> markerLocations = [
    LatLng(-33.796923, 151.144623),
    LatLng(-33.791923, 151.142623),
    LatLng(-33.788923, 151.148623),
  ];

  // Google Place Autocomplete
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    googlePlace = GooglePlace("AIzaSyDR-x7ACgDfqQ9D1Oi38zBV_WCPCYoFCZ4"); // Replace with your API key
    _searchController.addListener(() {
      autoCompleteSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlace(String placeName) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(placeName);
      if (locations.isNotEmpty) {
        final location = locations.first;
        LatLng newPosition = LatLng(location.latitude, location.longitude);

        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 14.0),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Place not found")),
        );
      }
    } catch (e) {
      debugPrint("Search Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error searching location")),
      );
    }
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      final location = loc.Location();
      final current = await location.getLocation();
      setState(() {
        _userLocation = LatLng(current.latitude!, current.longitude!);
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_userLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 14),
      );
    }
  }

  void _recenterMap() {
    if (_userLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 14),
      );
    }
  }

  // Google Place Autocomplete logic
  void autoCompleteSearch(String value) async {
    if (value.isNotEmpty) {
      final result = await googlePlace.autocomplete.get(value);
      if (result != null && result.predictions != null) {
        setState(() => predictions = result.predictions!);
      }
    } else {
      setState(() => predictions = []);
    }
  }

  void _selectPlace(String placeId) async {
    final detail = await googlePlace.details.get(placeId);
    if (detail != null && detail.result != null) {
      final lat = detail.result!.geometry!.location!.lat;
      final lng = detail.result!.geometry!.location!.lng;
      if (lat != null && lng != null) {
        LatLng newPosition = LatLng(lat, lng);
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 14.0),
        );
        setState(() {
          _searchController.clear();
          predictions = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          /// 🌍 Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _userLocation ?? const LatLng(-33.796923, 151.144623),
              zoom: 13.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              ...markerLocations.map(
                    (position) => Marker(
                  markerId: MarkerId(position.toString()),
                  position: position,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRose),
                  infoWindow: const InfoWindow(title: "Yummy"),
                ),
              ),
            },
          ),

          // 🔝 AppBar
          const GlassAppBar(),

          // 🔍 Search Bar
          Positioned(
            top: 110,
            left: 16,
            right: 16,
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 50,
              borderRadius: 15,
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black87),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "Search places",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.black87),
                        onSubmitted: (value) async {
                          await _searchPlace(value);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.black87),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            ),
          ),

          // 🔍 Suggestions Overlay (Dropdown)
          SearchSuggestionsOverlay(
            searchController: _searchController,
            predictions: predictions,
            onSuggestionTap: _selectPlace,
            onUseLocationTap: () {
              _recenterMap();
              setState(() {
                _searchController.clear();
                predictions = [];
              });
            },
          ),

          // 🔘 Category Chips
          Positioned(
            top: 170,
            left: 16,
            right: 0,
            child: CategoryChips(
              categories: categories,
              selectedIndex: selectedCategoryIndex,
              onSelected: (index) {
                setState(() {
                  selectedCategoryIndex = index;
                });
              },
            ),
          ),

          /// 🎯 Recenter FAB
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: const Icon(Icons.my_location, color: Colors.blueAccent),
              onPressed: _recenterMap,
            ),
          ),
        ],
      ),

      /// ⬇️ Bottom Navigation
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
