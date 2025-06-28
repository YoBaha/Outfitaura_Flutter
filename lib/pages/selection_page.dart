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

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WardrobeViewModel>(context, listen: false);
    debugPrint('clothingTypes: ${clothingTypes.join(', ')}');
    debugPrint('currentIndex: $currentIndex');
    final currentType = clothingTypes[currentIndex].trim().toLowerCase();
    debugPrint('currentType: $currentType');

    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${clothingTypes[currentIndex]}'),
      ),
      body: FutureBuilder<void>(
        future: viewModel.fetchFuture,
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
          final matchingItems = viewModel.items.where((item) {
            final itemTitle = item.title.toLowerCase().trim();
            debugPrint('Comparing item: "$itemTitle" with currentType: "$currentType"');
            return itemTitle == currentType;
          }).toList();
          debugPrint('Matching items for $currentType: ${matchingItems.map((i) => i.title).join(', ')}');

          // Check if currentType is valid
          const validTypes = {
            'shorts', 'sunglasses', 't-shirt', 'windbreaker', 'hoodie', 'sweater', 'umbrella',
          };
          final isValidType = validTypes.contains(currentType);

          return matchingItems.isEmpty || !isValidType
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isValidType
                            ? 'No items available for $currentType.'
                            : 'Invalid clothing type: ${clothingTypes[currentIndex]}.',
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => viewModel.fetchWardrobe(),
                        child: const Text('Refresh Wardrobe'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (currentIndex < clothingTypes.length - 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectionPage(
                                  clothingTypes: clothingTypes,
                                  selectedItems: selectedItems,
                                  currentIndex: currentIndex + 1,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FavoritesOutfitPage(selectedItems: selectedItems),
                              ),
                            );
                          }
                        },
                        child: const Text('Skip'),
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
                            ..[clothingTypes[currentIndex]] = item;
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