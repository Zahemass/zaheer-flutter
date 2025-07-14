import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:sample_proj/components/app_bar.dart';
import 'package:sample_proj/components/category_chips.dart';
import 'package:sample_proj/widgets/custom_bottom_nav.dart';
import 'package:sample_proj/components/GlassDetailBottomSheet.dart';
import 'package:sample_proj/screens/user_profile_screen.dart';
import './upload_screen.dart';
import './PlayPostScreen.dart'; // Adjust path as needed
import 'dart:ui' as ui; // Required for instantiateImageCodec
import 'dart:typed_data';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:string_similarity/string_similarity.dart';





class SimpleMapScreen extends StatefulWidget {
  final String username;

  const SimpleMapScreen({super.key, required this.username});

  @override
  State<SimpleMapScreen> createState() => _SimpleMapScreenState();
}

class _SimpleMapScreenState extends State<SimpleMapScreen> {

  Set<Marker> _dynamicMarkers = {};
  String? _selectedSpotUsername;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = '';

  final FlutterTts _flutterTts = FlutterTts();

  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').replaceAll('&', 'and').trim();
  }


  @override
  void initState() {
    super.initState();
    _initLocation();
    _speech = stt.SpeechToText();

  }

  void _startListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        print("🎙️ Speech status: $status");
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        print("❌ Speech error: $error");
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _voiceInput = '';
      });

      print("🎤 Listening...");

      _speech.listen(
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 10),
          onResult: (result) async {
            if (result.finalResult) {
              final spokenRaw = result.recognizedWords.trim();
              final normalizedSpoken = _normalize(spokenRaw);
              print("🎤 Spoken raw: '$spokenRaw'");
              print("🔎 Normalized spoken: '$normalizedSpoken'");

              /// 1. Check if user said "hi lenso"
              if (normalizedSpoken.contains("hi kira")) {
                await _flutterTts.speak("Hi ${widget.username}, How can I help you?");
              }

              /// 2. Check if sentence contains "sad"
              else if (normalizedSpoken.contains("sad")) {
                await _flutterTts.speak(
                  "I suggest you to go to Wild Garden Cafe nearby you. "
                      "Spend some me-time to feel better. Let me know if you want direction.",
                );
              }

              else if (normalizedSpoken.contains("happy")) {
                selectedCategoryIndex = categories.indexOf("Funny Tail");

                if (_liveLocation != null) {
                  await _fetchNearbySpots(_liveLocation!.latitude, _liveLocation!.longitude);
                }

                await _flutterTts.speak(
                  "Glad you're happy! Here are some Funny Tail spots nearby you. "
                      "If you want directions, just say 'show me direction' and I’ll take you there.",
                );
              }


              /// 3. If user says "ok show me a direction"
              else if (normalizedSpoken.contains("show me a direction")) {
                await _flutterTts.speak("Sure, showing you the direction now.");

                // 👇 Replace this with actual destination
                LatLng wildGardenCafe = LatLng(13.057002, 80.259509); // Wild Garden Cafe

                if (_liveLocation != null) {
                  _drawStraightLine(_liveLocation!, wildGardenCafe);
                  setState(() {
                    _selectedTitle = "Wild Garden Cafe";
                    _selectedDescription = "A peaceful place to relax and enjoy.";
                    _selectedViews = 125;
                    _selectedCoordinates = wildGardenCafe;
                  });
                }
              }

              /// 4. Else use category matching logic (your existing feature)
              else {
                double bestMatchScore = 0;
                int? bestMatchIndex;

                for (int i = 0; i < categories.length; i++) {
                  final normalizedCategory = _normalize(categories[i]);
                  double score = normalizedSpoken.similarityTo(normalizedCategory);

                  if (score > bestMatchScore) {
                    bestMatchScore = score;
                    bestMatchIndex = i;
                  }
                }

                if (bestMatchScore > 0.6 && bestMatchIndex != null) {
                  final categoryName = categories[bestMatchIndex];
                  setState(() => selectedCategoryIndex = bestMatchIndex!);

                  await _flutterTts.speak("Showing the $categoryName near by you");

                  if (_liveLocation != null) {
                    await _fetchNearbySpots(
                      _liveLocation!.latitude,
                      _liveLocation!.longitude,
                    );
                  }
                } else {
                  await _flutterTts.speak("Sorry, I couldn't find any category like that.");
                }
              }

              await _speech.stop();
              setState(() => _isListening = false);
            }
          }

      );
    } else {
      print("❌ Speech recognition not available");
    }
  }








  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }


  Future<void> getRoutePolyline(LatLng origin, LatLng destination) async {
    const apiKey = 'AIzaSyAMz0YusgtkPO3oyemCNGDqoydq5T3S3nw'; // 🔁 Replace this
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&mode=driving'
          '&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        final decodedPoints = _decodePolyline(points);

        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.blue,
              width: 5,
              points: decodedPoints,
            ),
          };
        });
      } else {
        print("No routes found");
      }
    } else {
      print("Directions API failed: ${response.statusCode}");
    }
  }

  //api
  Future<void> _initLocation() async {
    final LatLng defaultLocation = const LatLng(13.0740, 80.2616); // Egmore

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // 👇 Use default location (Egmore)
      setState(() => _liveLocation = defaultLocation);
      _fetchNearbySpots(defaultLocation.latitude, defaultLocation.longitude);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final currentLoc = LatLng(position.latitude, position.longitude);
      setState(() => _liveLocation = currentLoc);
      await _loadProfileMarkerIcon();
      _fetchNearbySpots(currentLoc.latitude, currentLoc.longitude);
    } catch (e) {
      // 👇 Fallback in case of any error while getting location
      setState(() => _liveLocation = defaultLocation);
      _fetchNearbySpots(defaultLocation.latitude, defaultLocation.longitude);
      print("⚠️ Location fetch failed, fallback to Egmore: $e");
    }


  }

  Future<void> _loadProfileMarkerIcon() async {
    final url = Uri.parse("http://192.168.29.68:4000/profilepicreturn"); // Update if needed

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": widget.username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profilePicUrl = data['profile_image'];

        if (profilePicUrl != null && profilePicUrl.isNotEmpty) {
          final imageResponse = await http.get(Uri.parse(profilePicUrl));
          if (imageResponse.statusCode == 200) {
            final Uint8List imageBytes = imageResponse.bodyBytes;

            // Decode image and resize
            final ui.Codec codec = await ui.instantiateImageCodec(
              imageBytes,
              targetWidth: 100,
              targetHeight: 100,
            );
            final ui.FrameInfo frame = await codec.getNextFrame();
            final ui.Image originalImage = frame.image;

            // Create circular image
            final ui.PictureRecorder recorder = ui.PictureRecorder();
            final Canvas canvas = Canvas(recorder);
            final Paint paint = Paint()..isAntiAlias = true;

            final double radius = 50;
            final Rect rect = Rect.fromLTWH(0, 0, 100, 100);
            final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

            canvas.clipRRect(rRect);
            canvas.drawImage(originalImage, Offset.zero, paint);

            final ui.Image circularImage = await recorder.endRecording().toImage(100, 100);
            final ByteData? byteData = await circularImage.toByteData(format: ui.ImageByteFormat.png);

            if (byteData != null) {
              final Uint8List markerIconBytes = byteData.buffer.asUint8List();

              setState(() {
                _profileMarkerIcon = BitmapDescriptor.fromBytes(markerIconBytes);
              });
            }
          }
        }
      } else {
        print("❌ API error: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Exception in loading marker icon: $e");
    }
  }




  Future<void> _fetchSearchedSpots(String searchQuery) async {
    final url = Uri.parse("http:// 192.168.29.68:4000/search-spots");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"SearchQuery": searchQuery}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List spots = data['spots'];

        final String imagePath = categoryToPinImage[categories[selectedCategoryIndex]] ?? 'assets/images/pin_1.png';

        final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(60, 60)),
          imagePath,
        );

        final markers = spots.map<Marker>((spot) {
          final lat = spot['latitude'] as double;
          final lng = spot['longitude'] as double;

          return Marker(
            markerId: MarkerId(spot['spotname']),
            position: LatLng(lat, lng),
            icon: customIcon,
            onTap: () {
              setState(() {
                _selectedTitle = spot['spotname'];
                _selectedDescription = spot['description'] ?? '';
                _selectedViews = spot['viewcount'] ?? 0;
                _selectedCoordinates = LatLng(lat, lng);
                _selectedSpotUsername = spot['username'];
              });
            },
          );
        }).toSet();

        setState(() {
          _dynamicMarkers = markers;
          _backendNearbySpots = List<Map<String, dynamic>>.from(spots);
        });
      } else {
        print("❌ Failed to fetch searched spots: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error fetching searched spots: $e");
    }
  }

  Future<void> _fetchNearbySpots(double lat, double lon) async {
    final String selectedCategory = categories[selectedCategoryIndex];
    final String categoryQuery = Uri.encodeComponent(selectedCategory);

    final url = Uri.parse("http://192.168.29.68:4000/nearby?lat=$lat&lng=$lon&SearchQuery=$categoryQuery");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final List<Map<String, dynamic>> filteredSpots = List<Map<String, dynamic>>.from(data);

        final String imagePath = categoryToPinImage[selectedCategory] ?? 'assets/images/pin_1.png';

        final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(60, 60)),
          imagePath,
        );

        final markers = filteredSpots.map((spot) {
          final lat = spot['latitude'] as double;
          final lng = spot['longitude'] as double;

          return Marker(
            markerId: MarkerId(spot['spotname']),
            position: LatLng(lat, lng),
            icon: customIcon,
            onTap: () async {
              try {
                final username = spot['username'];
                final latStr = lat.toString();
                final lonStr = lng.toString();

                final introUrl = Uri.parse(
                    "http://192.168.29.68:4000/spotintro?username=$username&lat=$latStr&lon=$lonStr"
                );

                final introResponse = await http.get(introUrl);
                if (introResponse.statusCode == 200) {
                  final introData = jsonDecode(introResponse.body);

                  setState(() {
                    _selectedTitle = introData['category'];
                    _selectedDescription = introData['description'];
                    _selectedViews = introData['viewcount'];
                    _selectedCoordinates = LatLng(lat, lng);
                    _selectedSpotUsername = username;
                  });
                } else {
                  print("❌ Failed to fetch spot intro: ${introResponse.statusCode}");
                }
              } catch (e) {
                print("⚠️ Error fetching spot intro: $e");
              }
            },
          );
        }).toSet();

        setState(() {
          _backendNearbySpots = filteredSpots;
          _dynamicMarkers = markers;
        });

        print("✅ Spots for category '$selectedCategory': $_backendNearbySpots");
      } else {
        print("❌ Failed to fetch spots: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error fetching spots: $e");
    }
  }



  GoogleMapController? _googleMapController;
  LatLng? _liveLocation;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  BitmapDescriptor? _profileMarkerIcon; // 👈 Add this
  String? _selectedTitle;
  String? _selectedDescription;
  int? _selectedViews;
  LatLng? _selectedCoordinates;

  Set<Polyline> _polylines = {}; // 🔹 For straight line drawing

  int selectedCategoryIndex = 0;
  int _selectedIndex = 0;

  final List<String> categories = [
    "Foodie Finds",
    "Funny Tail",
    "History Whishpers",
    "Hidden spots",
    "Art & Culture",
    "Legends & Myths",
    "Shopping Gems",
    "Festive Movements"
  ];

  final Map<String, String> categoryToPinImage = {
    "Foodie Finds": "assets/images/pin_1.png",
    "Funny Tail": "assets/images/funnytales.png",
    "History Whishpers": "assets/images/historywhishpers.png",
    "Hidden spots": "assets/images/hiddenspots.png",
    "Art & Culture": "assets/images/art&culture.png",
    "Legends & Myths": "assets/images/legends&myths.png",
    "Shopping Gems": "assets/images/shoppinggems.png",
    "Festive Movements": "assets/images/festivemovements.png",
  };

  List<Map<String, dynamic>> _backendNearbySpots = [];


  Future<void> _fetchSuggestions(String input) async {
    if (input.isEmpty) return;
    final url =
        "https://nominatim.openstreetmap.org/search?q=$input&format=json&limit=5&addressdetails=1";
    final response = await http.get(Uri.parse(url), headers: {
      "User-Agent": "FlutterMapApp"
    });
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() => _suggestions = List<Map<String, dynamic>>.from(data));
    }
  }

  Future<void> _onSuggestionTap(Map<String, dynamic> suggestion) async {
    final lat = double.parse(suggestion['lat']);
    final lon = double.parse(suggestion['lon']);
    final selected = LatLng(lat, lon);
    final query = suggestion['display_name'];

    setState(() {
      _searchController.text = query;
      _suggestions = [];
    });

    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(selected, 15),
    );

    await _fetchSearchedSpots(query); // 👈 fetch backend data for searched location
  }


  void _drawStraightLine(LatLng start, LatLng end) {
    getRoutePolyline(start, end);
  }


  Future<Set<Marker>> _buildMarkers() async {
    final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(60, 60)),
      'assets/images/pin_1.png',
    );

    final backendMarkers = _backendNearbySpots.map((spot) {
      final lat = spot['latitude'] as double;
      final lng = spot['longitude'] as double;

      return Marker(
        markerId: MarkerId(spot['spotname']),
        position: LatLng(lat, lng),
        icon: customIcon,
        onTap: () {
          setState(() {
            _selectedTitle = spot['spotname'];
            _selectedDescription = "Lat: $lat\nLng: $lng";
            _selectedViews = (spot['distance'] as num).round(); // using distance as "views"
            _selectedCoordinates = LatLng(lat, lng);
          });
        },
      );
    }).toSet();

    return backendMarkers;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_selectedTitle != null) {
            setState(() {
              _selectedTitle = null;
              _polylines = {}; // clear route when closing detail
            });
          }
        },
        child: Stack(

          children: [


            if (_liveLocation == null)
              const Center(child: CircularProgressIndicator())
            else
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _liveLocation!,
                  zoom: 14,
                ),
                onMapCreated: (controller) => _googleMapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: {
                  if (_liveLocation != null)
                    Marker(
                      markerId: const MarkerId("live"),
                      position: _liveLocation!,
                      icon: _profileMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      infoWindow: const InfoWindow(title: "You"),
                    ),
                  ..._dynamicMarkers, // 👈 We'll define this below
                },
                polylines: _polylines,
              ),

            Positioned(
              bottom: 160,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.black87,
                onPressed: _startListening,
                child: Icon(
                  _isListening ? Icons.mic_none : Icons.mic,
                  color: Colors.white,
                ),

              ),
            ),
            const GlassAppBar(),

            Positioned(
              top: 110,
              left: 15,
              right: 15,
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 55,
                borderRadius: 12,
                blur: 15,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white38.withOpacity(0.2)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white24.withOpacity(0.2),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.search, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _fetchSuggestions,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "Search places...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),

            Positioned(
              top: 175,
              left: 16,
              right: 0,
              child: CategoryChips(
                categories: categories,
                selectedIndex: selectedCategoryIndex,
                onSelected: (index) {
                  setState(() {
                    selectedCategoryIndex = index;
                    final selectedCategory = categories[index];
                    if (_liveLocation != null) {
                      _fetchNearbySpots(_liveLocation!.latitude, _liveLocation!.longitude);
                    }

                  });
                },
              ),
            ),

            if (_suggestions.isNotEmpty)
              Positioned(
                top: 230,
                left: 15,
                right: 15,
                child: GlassmorphicContainer(
                  width: double.infinity,
                  height: _suggestions.length * 55.0,
                  borderRadius: 12,
                  blur: 20,
                  alignment: Alignment.topCenter,
                  border: 1,
                  linearGradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white38.withOpacity(0.2)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white24.withOpacity(0.2),
                    ],
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_on, color: Colors.black),
                        title: Text(
                          suggestion['display_name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black),
                        ),
                        onTap: () => _onSuggestionTap(suggestion),
                      );
                    },
                  ),
                ),
              ),

            if (_selectedTitle != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 95,
                child: GestureDetector(
                  onTap: () {}, // prevent tap propagation
                  child: GlassDetailBottomSheet(
                    title: _selectedTitle!,
                    description: _selectedDescription ?? '',
                    views: _selectedViews ?? 0,
                    onDirectionTap: () {
                      if (_liveLocation != null && _selectedCoordinates != null) {
                        _drawStraightLine(_liveLocation!, _selectedCoordinates!);
                      }
                    },
                    onPlayTap: () {
                      if (_selectedCoordinates != null &&
                          _selectedDescription != null &&
                          _selectedViews != null &&
                          _selectedTitle != null)

                        print("▶️ Spot Username: $_selectedSpotUsername");

                      {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayPostScreen(
                              username: _selectedSpotUsername ?? widget.username,
                              description: _selectedDescription!,
                              views: _selectedViews!,
                              latitude: _selectedCoordinates!.latitude,
                              longitude: _selectedCoordinates!.longitude,
                            ),
                          ),
                        );
                      }
                    },
                    onCloseTap: () {
                      setState(() {
                        _selectedTitle = null;
                        _selectedDescription = null;
                        _selectedViews = null;
                        _selectedCoordinates = null;
                        _polylines.clear(); // optional: clear route
                      });
                    },

                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UploadScreen(username: widget.username)),
            );
          }else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserProfileScreen(username: widget.username)),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),

    );
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
