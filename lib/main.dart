import 'package:flutter/material.dart';
import 'package:sample_proj/screens/welcome_page.dart';
import 'screens/upload_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Lens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: const UploadScreen(),
    );
  }
}