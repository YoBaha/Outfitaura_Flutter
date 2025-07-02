import 'package:flutter/material.dart';
import 'package:outfitaura/services/api_service.dart';
import 'package:outfitaura/pages/selection_page.dart';
import 'package:outfitaura/pages/extensions.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 8),
            const Text(
              'Clothing Recommendation',
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
      body: Container(
        color: const Color(0xFFDDEAE0),
        child: FutureBuilder<String>(
          future: ApiService.getRecommendation(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF007180)));
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.error.toString().contains('not available yet')
                          ? 'Recommendation not ready. Please try again.'
                          : 'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                      style: const TextStyle(color: Color(0xFFE15757), fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ACDEB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const RecommendationPage()),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No recommendation available', style: TextStyle(color: Color(0xFF007180))),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ACDEB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const RecommendationPage()),
                      ),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            // Normalize recommendation string
            final recommendation = snapshot.data!
                .replaceFirst(RegExp(r'👕\s*Recommended:\s*'), '') // Remove emoji and "Recommended:"
                .replaceAll(RegExp(r'[^\w\s,-]'), '') // Remove special characters except commas and hyphens
                .trim();
            debugPrint('Recommendation raw: $recommendation');

            // Split on commas, "or", or multiple spaces
            List<String> clothingTypes = recommendation
                .split(RegExp(r'\s*(,|or|\s+)\s*'))
                .map((e) => e.trim().toLowerCase())
                .where((e) => e.isNotEmpty)
                .toList();

            // Define valid clothing types
            const validTypes = {
              'shorts', 'sunglasses', 't-shirt', 'windbreaker', 'hoodie', 'sweater', 'umbrella',
              'jacket', 'shirt', 'pants', 'dress', 'skirt', 'hat', 'scarf', 'gloves', 'warm clothes', 'jeans'
            };

            // Normalize and filter clothing types
            clothingTypes = clothingTypes
                .map((type) {
                  // Handle common variations
                  if (type.contains('tshirt')) return 't-shirt';
                  if (type.contains('jean')) return 'jeans';
                  if (type.contains('wind breaker') || type.contains('windbreaker')) return 'windbreaker';
                  return type;
                })
                .where((type) => validTypes.contains(type))
                .toSet()
                .toList(); // Remove duplicates

            debugPrint('Parsed clothing types: ${clothingTypes.join(', ')}');

            if (clothingTypes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Invalid recommendation format',
                      style: TextStyle(color: Color(0xFFE15757), fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ACDEB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const RecommendationPage()),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Recommended Clothing',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF007180),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      clothingTypes.map((type) => type.capitalize()).join(', '),
                      style: const TextStyle(fontSize: 18, color: Color(0xFF007180)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ACDEB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        debugPrint('Navigating to SelectionPage with clothingTypes: ${clothingTypes.join(', ')}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectionPage(
                              clothingTypes: clothingTypes,
                              selectedItems: {},
                              currentIndex: 0,
                            ),
                          ),
                        );
                      },
                      child: const Text('Make Outfit', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}