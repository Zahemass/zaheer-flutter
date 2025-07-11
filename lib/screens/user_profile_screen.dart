// ✅ FULLY UPDATED CODE
// - profile_image from backend shown
// - PostPointsRow and PostCard made dynamic

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/app_bar.dart';
import 'dart:ui';
import 'package:sample_proj/widgets/custom_bottom_nav.dart';
import 'simple_map_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  final String username;
  const UserProfileScreen({super.key, required this.username});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? profileImageUrl;
  String? fetchedUsername;
  int postCount = 0;
  int badgeScore = 0;
  List<Map<String, dynamic>> uploadedSpots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile(widget.username);
  }

  Future<void> fetchUserProfile(String username) async {
    final url = Uri.parse("http://192.168.29.17:4000/return-profile");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          fetchedUsername = data['username'];
          postCount = data['postcount'];
          badgeScore = data['score'];
          uploadedSpots = List<Map<String, dynamic>>.from(data['uploaded_spots']);
          profileImageUrl = data['profile_image'];
          isLoading = false;
        });
      } else {
        print("❌ Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error fetching profile: $e");
    }
  }

  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8EE),
      body: Column(
        children: [
          const GlassAppBar(),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black12,
                    image: profileImageUrl != null
                        ? DecorationImage(
                      image: NetworkImage(profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: profileImageUrl == null
                      ? const Center(child: Icon(Icons.person, size: 45, color: Colors.black54))
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      fetchedUsername ?? widget.username,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GlassButton(
                      text: "Edit profile",
                      onTap: () {},
                    ),
                  ],
                ),
                const Spacer(),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
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
          PostPointsRow(postCount: postCount, badgeScore: badgeScore),
          const SizedBox(height: 20),

          if (!isLoading)
            ...uploadedSpots.map((spot) => PostCard(
              title: spot['title'],
              views: spot['viewscount'],
              likes: spot['likescount'],
              imageUrl: spot['spotimage'],
            )),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
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

class PostPointsRow extends StatelessWidget {
  final int postCount;
  final int badgeScore;
  const PostPointsRow({super.key, required this.postCount, required this.badgeScore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Post', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      Image.asset('assets/images/post_icon.png', width: 22, height: 22, color: Colors.white),
                    ],
                  ),
                  const Spacer(),
                  Text('$postCount', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Badges', style: GoogleFonts.montserrat(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
                      Image.asset('assets/images/points_icon.png', width: 22, height: 22),
                    ],
                  ),
                  const Spacer(),
                  Text('$badgeScore', style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String title;
  final int views;
  final int likes;
  final String imageUrl;
  const PostCard({super.key, required this.title, required this.views, required this.likes, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9DDE3),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye, size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text('$views', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black54)),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite, size: 16, color: Colors.pink),
                      const SizedBox(width: 4),
                      Text('$likes', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

