import 'package:flutter/material.dart';
import 'package:outfitaura/models/clothing_item.dart';
import 'package:outfitaura/services/api_service.dart';

class FavoritesOutfitPage extends StatelessWidget {
  final Map<String, ClothingItem> selectedItems;

  const FavoritesOutfitPage({super.key, required this.selectedItems});

  Future<void> _saveOutfit(BuildContext context) async {
    try {
      final items = selectedItems.entries.map((entry) => {
        'type': entry.key,
        'clothingItemId': entry.value.id, 
        'title': entry.value.title,
        'imageUrl': entry.value.imageUrl,
        'createdAt': entry.value.createdAt.toIso8601String(),
      }).toList();
      await ApiService.saveFavoriteOutfit({'items': items});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit saved to favorites!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save outfit: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites Outfit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Your Outfit',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...selectedItems.entries.map((entry) {
              final type = entry.key;
              final item = entry.value;
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Image.network(
                    item.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                  ),
                  title: Text('$type: ${item.title}'),
                  subtitle: Text('Added: ${item.createdAt.toLocal().toString().split('.')[0]}'),
                ),
              );
            }).toList(),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ACDEB)),
              onPressed: () async {
                await _saveOutfit(context);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Save and Back to Home', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}