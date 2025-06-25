import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:outfitaura/models/clothing_item.dart';
import 'package:outfitaura/viewmodels/wardrobe_viewmodel.dart';
import 'package:outfitaura/pages/favorites_outfit_page.dart';

class SelectionPage extends StatelessWidget {
  final List<String> clothingTypes;
  final Map<String, ClothingItem> selectedItems;
  final int currentIndex;

  const SelectionPage({
    super.key,
    required this.clothingTypes,
    required this.selectedItems,
    required this.currentIndex,
  });

// ... (previous imports and class definition remain the same)

@override
Widget build(BuildContext context) {
  final viewModel = Provider.of<WardrobeViewModel>(context, listen: false);
  final currentType = clothingTypes[currentIndex].trim();

  return Scaffold(
    appBar: AppBar(
      title: Text('Select $currentType'),
    ),
    body: FutureBuilder<void>(
      future: viewModel.fetchWardrobe(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('SelectionPage error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => viewModel.fetchWardrobe(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        debugPrint('Wardrobe items: ${viewModel.items.map((i) => i.title).join(', ')}');
        final matchingItems = viewModel.items.where((item) => item.title.toLowerCase().trim() == currentType.toLowerCase()).toList();
        debugPrint('Matching items for $currentType: ${matchingItems.map((i) => i.title).join(', ')}');

        return matchingItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No items available for this type.'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => viewModel.fetchWardrobe(),
                      child: const Text('Refresh Wardrobe'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: matchingItems.length,
                itemBuilder: (context, index) {
                  final item = matchingItems[index];
                  debugPrint('Displaying item: ${item.title}, URL: ${item.imageUrl}');
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
                      title: Text(item.title),
                      subtitle: Text('Added: ${item.createdAt.toLocal().toString().split('.')[0]}'),
                      onTap: () {
                        final updatedSelectedItems = Map<String, ClothingItem>.from(selectedItems)
                          ..[currentType] = item;
                        if (currentIndex < clothingTypes.length - 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectionPage(
                                clothingTypes: clothingTypes,
                                selectedItems: updatedSelectedItems,
                                currentIndex: currentIndex + 1,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FavoritesOutfitPage(selectedItems: updatedSelectedItems),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
      },
    ),
  );
}
}