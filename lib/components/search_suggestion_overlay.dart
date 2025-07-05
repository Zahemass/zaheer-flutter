import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_place/google_place.dart';

class SearchSuggestionsOverlay extends StatelessWidget {
  final TextEditingController searchController;
  final List<AutocompletePrediction> predictions;
  final Function(String placeId) onSuggestionTap;
  final VoidCallback onUseLocationTap;

  const SearchSuggestionsOverlay({
    Key? key,
    required this.searchController,
    required this.predictions,
    required this.onSuggestionTap,
    required this.onUseLocationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchController.text.isEmpty || predictions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: 160,
      left: 16,
      right: 16,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 20,
        borderRadius: 10,
        blur: 20,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 250,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: const Icon(Icons.my_location),
                title: const Text("Use my location"),
                onTap: onUseLocationTap,
              ),
              ...predictions.map((p) => ListTile(
                title: Text(p.description ?? ""),
                onTap: () => onSuggestionTap(p.placeId!),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
