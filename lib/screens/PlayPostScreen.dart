import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/custom_bottom_nav.dart';

class PlayPostScreen extends StatefulWidget {
  final String username;
  final String description;
  final int views;
  final double latitude;
  final double longitude;

  const PlayPostScreen({
    super.key,
    required this.username,
    required this.description,
    required this.views,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<PlayPostScreen> createState() => _PlayPostScreenState();
}

class _PlayPostScreenState extends State<PlayPostScreen> {
  bool isLiked = false;
  bool showBigHeart = false;
  bool isPlaying = true;
  bool showControlIcon = false;
  bool isExpanded = false;
  IconData currentControlIcon = Icons.pause;

  void _handleDoubleTap() {
    setState(() {
      isLiked = true;
      showBigHeart = true;
    });

    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => showBigHeart = false);
      }
    });
  }

  void _handleSingleTap() {
    setState(() {
      isPlaying = !isPlaying;
      currentControlIcon = isPlaying ? Icons.play_arrow : Icons.pause;
      showControlIcon = true;
    });

    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => showControlIcon = false);
      }
    });
  }

  String selectedLanguage = "English";

  void _showLanguagePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: GlassmorphicContainer(
              width: 300,
              height: 250,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
              ),
              borderGradient: LinearGradient(
                colors: [Colors.white24, Colors.white10],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Choose Language",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                      decoration: TextDecoration.none, // No underline
                    ),
                  ),
                  const SizedBox(height: 20),
                  _languageOption("English"),
                  _languageOption("Hindi"),
                  _languageOption("French"),
                  _languageOption("German"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _languageOption(String language) {
    final isSelected = selectedLanguage == language;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = language;
          Navigator.pop(context); // close popup
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          language,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            decoration: TextDecoration.none, // ✅ Ensures no underline on tap/select
          ),
        ),
      ),
    );
  }

  void _showSummaryPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: GlassmorphicContainer(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 350,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
              ),
              borderGradient: LinearGradient(
                colors: [Colors.white24, Colors.white10],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📖 Title: Beautiful Chennai",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "✨ Summary: Chennai is known for its cultural heritage and stunning architecture.",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.white70,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          "🌆 Paragraph:\nChennai, the capital of Tamil Nadu, offers a blend of tradition and modernity. It’s home to beautiful temples, beaches, and a rich cultural scene. The city embraces both classical art and contemporary tech culture, making it a unique destination for both tourists and locals.",
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.white,
                            height: 1.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final String shortDescription = widget.description.length > 100
        ? widget.description.substring(0, 100)
        : widget.description;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: GestureDetector(
              onTap: _handleSingleTap,
              onDoubleTap: _handleDoubleTap,
              child: Image.asset(
                'assets/images/sample_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Big Heart Animation
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showBigHeart ? 1.0 : 0.0,
              child: Icon(
                Icons.favorite,
                size: 100,
                color: Colors.pinkAccent.withOpacity(0.9),
              ),
            ),
          ),

          // Play/Pause Icon
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showControlIcon ? 1.0 : 0.0,
              child: GlassmorphicContainer(
                width: 100,
                height: 100,
                borderRadius: 50,
                blur: 20,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                ),
                borderGradient: LinearGradient(
                  colors: [Colors.white24, Colors.white10],
                ),
                child: Icon(
                  currentControlIcon,
                  size: 50,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),

          // Top Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // Bottom Gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // Glass AppBar
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 60,
              borderRadius: 16,
              blur: 10,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.1), Colors.white38.withOpacity(0.1)],
              ),
              borderGradient: LinearGradient(
                colors: [Colors.white24, Colors.white10],
              ),
              child: Center(
                child: Text(
                  "LOCAL LENS",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Summary Icon
          Positioned(
            top: 110,
            right: 20,
            child: GestureDetector(
              onTap: () => _showSummaryPopup(context),
              child: GlassmorphicContainer(
                width: 45,
                height: 45,
                borderRadius: 12,
                blur: 10,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                ),
                borderGradient: LinearGradient(
                  colors: [Colors.white24, Colors.white10],
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),

          // Right Icons Stack
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => isLiked = !isLiked),
                  child: _glassIcon(
                    Iconsax.heart5,
                    iconColor: isLiked ? Colors.pinkAccent : Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _glassIcon(Iconsax.location),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _showLanguagePopup(context),
                  child: _glassIcon(Iconsax.message_text),
                ),

              ],
            ),
          ),

          // Profile Info & See More Description
          Positioned(
            left: 16,
            right: 16,
            bottom: isExpanded ? MediaQuery.of(context).size.height * 0.4 : 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.username,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => isExpanded = !isExpanded),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: isExpanded ? 12 : 14, // Smaller when expanded
                      ),
                      children: [
                        TextSpan(
                          text: shortDescription,
                        ),
                        if (widget.description.length > 100)
                          TextSpan(
                            text: isExpanded ? '  see less' : '... see more',
                            style: const TextStyle(
                              color: Colors.pinkAccent, // 🎯 Make it stand out
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                if (!isExpanded)
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.white70, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.views} views",
                        style: GoogleFonts.montserrat(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // Expanded Glass Panel
          // Expanded Glass Panel
          if (isExpanded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.4, // Mid-screen height
              child: Stack(
                children: [
                  // Background Image for blur
                  Positioned.fill(
                    child: Image.asset('assets/pop.png', fit: BoxFit.cover),
                  ),
                  // Blur + White Panel
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username + Direction
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.username,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.directions, size: 18, color: Colors.black87),
                                      const SizedBox(width: 5),
                                      Text(
                                        "Direction",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.remove_red_eye, size: 20, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  "${widget.views} views",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        widget.description,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color: Colors.white,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => setState(() => isExpanded = false),
                                      child: Text(
                                        "see less",
                                        style: GoogleFonts.montserrat(
                                          color: Colors.pinkAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          // Navigation logic
        },
      ),
    );
  }

  Widget _glassIcon(IconData icon, {Color iconColor = Colors.white}) {
    return GlassmorphicContainer(
      width: 50,
      height: 50,
      borderRadius: 25,
      blur: 15,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
      ),
      borderGradient: LinearGradient(
        colors: [Colors.white24, Colors.white10],
      ),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }
}
