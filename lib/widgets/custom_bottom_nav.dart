import 'dart:ui';
import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      height: 100,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // 🔵 Blur only inside this nav bar area
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.transparent,
              ),
            ),

            // 🧊 PNG Image on top of blur
            Positioned.fill(
              child: Image.asset(
                'assets/images/bottomnav.png',
                fit: BoxFit.cover,
              ),
            ),

            // 🔘 Icons
            Positioned(
              bottom: 33, // 👈 Adjust this to move icons further down
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavIcon(Icons.push_pin_rounded, 0),
                  _buildNavIcon(Icons.upload_rounded, 1),
                  _buildNavIcon(Icons.person, 2),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isActive ? Colors.redAccent : Colors.black.withOpacity(0.8),
        ),
      ),
    );
  }
}
