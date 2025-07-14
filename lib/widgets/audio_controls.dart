import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class AudioControls extends StatelessWidget {
  final bool isRecording;
  final int recordedSeconds;
  final VoidCallback onAudioOptions;
  final VoidCallback onStopRecording;
  final VoidCallback onAddThumbnail;

  const AudioControls({
    super.key,
    required this.isRecording,
    required this.recordedSeconds,
    required this.onAudioOptions,
    required this.onStopRecording,
    required this.onAddThumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return isRecording
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // 🌫️ Glass background
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                ),

                // 🔴 Recording progress
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: recordedSeconds / 45.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.pink.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),

                // ⏹️ Stop Button
                Container(
                  height: 60,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.stop_circle, color: Colors.red),
                    label: Text(
                      "Stop Recording",
                      style: GoogleFonts.montserrat(color: Colors.black87),
                    ),
                    onPressed: onStopRecording,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: BorderSide.none,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black87,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "⏱ $recordedSeconds seconds",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    )
        : Row(
      children: [
        Expanded(
          child: _whiteGlassButton(
            icon: Iconsax.microphone,
            text: "Audio Record",
            onTap: onAudioOptions,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _whiteGlassButton(
            icon: Icons.image,
            text: "Add Thumbnail",
            onTap: onAddThumbnail,
          ),
        ),
      ],
    );
  }

  Widget _whiteGlassButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.white.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: TextButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: Colors.black87),
              label: Text(
                text,
                style: GoogleFonts.montserrat(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
