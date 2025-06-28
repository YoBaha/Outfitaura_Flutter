import 'package:flutter/material.dart';
import 'package:outfitaura/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:outfitaura/viewmodels/wardrobe_viewmodel.dart'; 

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', 
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'Favorites',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF007180),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.getFavoriteOutfits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF007180)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: const Color(0xFFE15757).withOpacity(0x1),
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Color(0xFFE15757), fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No favorite outfits yet',
                style: TextStyle(fontSize: 18, color: Color(0xFF007180)),
              ),
            );
          }

          final favorites = snapshot.data!;
          return Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: const Color(0xFF82BECC),
            margin: const EdgeInsets.all(16),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: const Color(0xFFDDEAE0),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Outfit Created: ${favorite['createdAt'].toLocal().toString().split('.')[0]}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF007180)),
                        ),
                      ),
                      ...favorite['items'].map<Widget>((item) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: Image.network(
                            item['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
                          ),
                          title: Text(
                            '${item['type']}: ${item['title']}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF007180)),
                          ),
                          subtitle: Text(
                            'Added: ${item['createdAt'].toLocal().toString().split('.')[0]}',
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}