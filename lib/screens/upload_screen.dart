import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../components/app_bar.dart';
import '../components/category_chips.dart';
import '../widgets/custom_bottom_nav.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int selectedCategoryIndex = 0;
  int _selectedIndex = 0;

  final List<String> categories = [
    "Food", "Fun", "History", "Hidden spots", "Art & Culture"
  ];

  final Map<String, String> categoryEmojis = {
    "Food": "🍔",
    "Fun": "🎢",
    "History": "🏛️",
    "Hidden spots": "🗝️",
    "Art & Culture": "🎨",
  };

  File? _thumbnail;
  File? _uploadedAudio;
  String? _recordedAudioPath;
  bool _isRecording = false;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    await Permission.microphone.request();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _pickThumbnail(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _thumbnail = File(pickedFile.path));
    }
  }

  Future<void> _uploadAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _uploadedAudio = File(result.files.single.path!);
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordedAudioPath = path;
        _uploadedAudio = null; // override uploaded if recorded
      });
    } else {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/recorded_audio.aac';
      await _recorder.startRecorder(toFile: path);
      setState(() => _isRecording = true);
    }
  }

  void _pickLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📍 Location picker placeholder")),
    );
  }

  void _showAudioOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text("Record Audio"),
            onTap: () {
              Navigator.pop(context);
              _toggleRecording();
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text("Upload Audio"),
            onTap: () async {
              Navigator.pop(context);
              await _uploadAudioFile();
            },
          ),
        ],
      ),
    );
  }

  void _showThumbnailOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Upload from Gallery"),
            onTap: () {
              Navigator.pop(context);
              _pickThumbnail(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Take a Photo"),
            onTap: () {
              Navigator.pop(context);
              _pickThumbnail(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = categories[selectedCategoryIndex];
    final emoji = categoryEmojis[selectedCategory] ?? "🏷️";

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFFE4EC),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 120, bottom: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  CategoryChips(
                    categories: categories,
                    selectedIndex: selectedCategoryIndex,
                    onSelected: (index) {
                      setState(() => selectedCategoryIndex = index);
                    },
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Iconsax.add_circle),
                          label: const Text("Add Location"),
                          onPressed: _pickLocation,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: const BorderSide(color: Colors.black26),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      _roundedButton(
                        icon: Iconsax.microphone,
                        text: "Audio Options",
                        onTap: _showAudioOptions,
                      ),
                      const SizedBox(width: 12),
                      _roundedButton(
                        icon: Iconsax.gallery,
                        text: "Thumbnail Options",
                        onTap: _showThumbnailOptions,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (_thumbnail != null) ...[
                    const Text("Thumbnail Preview:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_thumbnail!, width: double.infinity, height: 200, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_recordedAudioPath != null) ...[
                    const Text("Recorded Audio:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("🎤 ${_recordedAudioPath!.split('/').last}"),
                    const SizedBox(height: 16),
                  ] else if (_uploadedAudio != null) ...[
                    const Text("Uploaded Audio:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("🎵 ${_uploadedAudio!.path.split('/').last}"),
                    const SizedBox(height: 16),
                  ],

                  _inputField(hint: "Add Title", controller: _titleController),
                  const SizedBox(height: 16),

                  _inputField(hint: "Description", controller: _descriptionController, maxLines: 4),
                  const SizedBox(height: 32),

                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter a title")),
                          );
                          return;
                        }
                        // 🔁 Upload logic goes here
                      },
                      icon: const Icon(Icons.upload, size: 18),
                      label: const Text("Upload"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0048),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const GlassAppBar(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _roundedButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return Expanded(
      child: OutlinedButton.icon(
        icon: Icon(icon, color: const Color(0xFFFF0048)),
        label: Text(text, style: const TextStyle(color: Colors.black87)),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _inputField({required String hint, required TextEditingController controller, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Colors.black45),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
      ),
    );
  }
}
