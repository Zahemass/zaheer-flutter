import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';


/// A reusable rounded button with icon and label.
Widget roundedButton({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
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

/// A reusable text input field.
Widget inputField({
  required String hint,
  required TextEditingController controller,
  int maxLines = 1,
}) {
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



