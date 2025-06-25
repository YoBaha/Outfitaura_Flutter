//where the outfit get saved at the end to naviagt to from the home page :)

import 'package:flutter/material.dart';
import 'package:outfitaura/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:outfitaura/viewmodels/wardrobe_viewmodel.dart'; // Assuming WardrobeViewModel is used

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.getFavoriteOutfits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorite outfits yet'));
          }

          final favorites = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outfit Created: ${favorite['createdAt'].toLocal().toString().split('.')[0]}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ...favorite['items'].map<Widget>((item) {
                      return ListTile(
                        leading: Image.network(
                          item['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        ),
                        title: Text('${item['type']}: ${item['title']}'),
                        subtitle: Text('Added: ${item['createdAt'].toLocal().toString().split('.')[0]}'),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}