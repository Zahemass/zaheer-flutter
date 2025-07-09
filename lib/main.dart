import 'package:flutter/material.dart';
import 'package:sample_proj/screens/welcome_page.dart';
import 'package:sample_proj/screens/PlayPostScreen.dart';


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
      home: PlayPostScreen(
        username: 'Zaheer',
        description: '“When you resume exercise after a break, your music ……”“When you resume exercise after a break, your music ……”“When you resume exercise after a break, your music ……”',
        views: 12026,
        latitude: 13.0827,
        longitude: 80.2707,
      ),
    );
  }
}