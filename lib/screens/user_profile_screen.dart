import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/app_bar.dart';
import 'dart:ui'; // for ImageFilter.blur
import 'package:sample_proj/widgets/post_points_row.dart';
import 'package:sample_proj/widgets/Postcard.dart';
import 'package:sample_proj/widgets/custom_bottom_nav.dart';
import 'simple_map_screen.dart';
import 'upload_screen.dart';


class UserProfileScreen extends StatefulWidget {

  final String username;

  const UserProfileScreen({super.key, required this.username});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final String userName = "genzyzubair";

  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8EE),
      body: Column(
        children: [
          const GlassAppBar(),
          const SizedBox(height: 20),

          // Profile Row with Settings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black12,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 45, color: Colors.black54),
                  ),
                ),

                const SizedBox(width: 16),

                // Username + Edit Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      userName,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GlassButton(
                      text: "Edit profile",
                      onTap: () {
                        // Add action here
                      },
                    ),
                  ],
                ),

                const Spacer(),

                // Settings Icon (top aligned)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child:ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                        ),
                        child: const Icon(Icons.settings, color: Colors.black),
                      ),
                    ),
                  ),

                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const PostPointsRow(),
          const SizedBox(height: 20),
          const PostCard(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            // Go to map screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SimpleMapScreen(username: widget.username),
              ),
            );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),

    );
  }
}

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const GlassButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [Colors.pinkAccent.withOpacity(0.6), Colors.pink.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
