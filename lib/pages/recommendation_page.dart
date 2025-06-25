import 'package:flutter/material.dart';
import 'package:outfitaura/services/api_service.dart';
import 'package:outfitaura/pages/selection_page.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothing Recommendation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<String>(
        future: ApiService.getRecommendation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const RecommendationPage()),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No recommendation available'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const RecommendationPage()),
                    ),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          final recommendation = snapshot.data!.replaceFirst('Recommended: ', '').trim(); // Remove prefix
          final clothingTypes = recommendation.split(' or ').map((e) => e.trim()).toList(); // Split on "or"

          debugPrint('Parsed clothing types: ${clothingTypes.join(', ')}');

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Recommended Clothing',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    recommendation,
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ACDEB)),
                    onPressed: clothingTypes.isNotEmpty
                        ? () {
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
                          }
                        : null,
                    child: const Text('Make Outfit', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}