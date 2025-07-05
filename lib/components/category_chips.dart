import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryChips({
    Key? key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.only(right: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: GlassmorphicContainer(
              width: 110,
              height: 45,
              borderRadius: 10,
              blur: 30,
              alignment: Alignment.center,
              border: 1.5,
              linearGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(isSelected ? 0.25 : 0.15),
                  Colors.white.withOpacity(isSelected ? 0.1 : 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isSelected
                      ? Colors.redAccent
                      : Colors.black87.withOpacity(0.7),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
