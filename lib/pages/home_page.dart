import 'package:flutter/material.dart';
import 'package:outfitaura/pages/login_page.dart';
import 'package:outfitaura/pages/recommendation_page.dart';
import 'package:outfitaura/services/api_service.dart';
import 'package:outfitaura/pages/wardrobe_page.dart';
import 'package:outfitaura/pages/statistics_page.dart'; // Added for navigation

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _logout(BuildContext context) async {
    await ApiService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // Search Field Widget
  Widget _buildSearchField(Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search clothes, styles, trends...',
          prefixIcon: Icon(Icons.search, color: primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // Category Icon Widget
  Widget _categoryIcon(IconData icon, String label, Color primaryColor, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: primaryColor.withOpacity(0.2),
            child: Icon(icon, size: 24, color: primaryColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: primaryColor),
          ),
        ],
      ),
    );
  }

  // Category Row Widget
  Widget _buildCategoryRow(BuildContext context, Color primaryColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _categoryIcon(Icons.recommend, 'Recomm..', primaryColor,
              onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecommendationPage()),
                  )),
          const SizedBox(width: 8),
          _categoryIcon(Icons.store, 'Marketplace', primaryColor,
              onTap: () => Navigator.pushNamed(context, '/marketplace')),
          const SizedBox(width: 8),
          _categoryIcon(Icons.style, 'Wardrobe', primaryColor,
              onTap: () => Navigator.pushNamed(context, '/wardrobe')),
          const SizedBox(width: 8),
          _categoryIcon(Icons.shopping_cart, 'Cart', primaryColor,
              onTap: () => Navigator.pushNamed(context, '/cart')),
          const SizedBox(width: 8),
          _categoryIcon(Icons.favorite, 'Favorites', primaryColor,
              onTap: () => Navigator.pushNamed(context, '/favorites')),
          // Add Statistics for admins
          FutureBuilder<Map<String, dynamic>?>(
            future: ApiService.getUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                return const SizedBox.shrink();
              }
              if (snapshot.data?['role'] == 'admin') {
                return Row(
                  children: [
                    const SizedBox(width: 8),
                    _categoryIcon(Icons.bar_chart, 'Statistics', primaryColor,
                        onTap: () => Navigator.pushNamed(context, '/statistics')),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 80,
              ),
              const SizedBox(width: 8),
              const Text(
                'OUTFITAURA',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF007180),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: Container(
          color: const Color(0xFFDDEAE0),
          child: FutureBuilder<List<dynamic>>(
            future: Future.wait([ApiService.getUser(), ApiService.getWeather()]),
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
                        'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                        style: const TextStyle(color: Color(0xFFE15757), fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ACDEB)),
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        ),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              }

              final userData = snapshot.data![0] as Map<String, dynamic>?;
              final weatherData = snapshot.data![1] as Map<String, dynamic>;

              String welcomeMessage = 'Welcome to OUTFITAURA!';
              if (userData != null) {
                welcomeMessage = 'Welcome, ${userData['name']}!';
                if (userData['role'] == 'admin') {
                  welcomeMessage += ' (Admin)';
                }
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        welcomeMessage,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF007180),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSearchField(const Color(0xFF007180)),
                      const SizedBox(height: 20),
                      _buildCategoryRow(context, const Color(0xFF007180)),
                      const SizedBox(height: 20),
                      Card(
                        color: const Color(0xFF82BECC),
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Weather',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (weatherData.containsKey('error'))
                                Text(
                                  'Weather Error: ${weatherData['error'].replaceFirst('Exception: ', '')}',
                                  style: const TextStyle(color: Color(0xFFE15757), fontSize: 16),
                                )
                              else ...[
                                const SizedBox(height: 12),
                                _buildWeatherRow('Condition', weatherData['condition']),
                                _buildWeatherRow('Temperature', '${weatherData['temperature'].toStringAsFixed(1)} °C'),
                                _buildWeatherRow('Humidity', '${weatherData['humidity']} %'),
                                _buildWeatherRow('Wind Speed', '${weatherData['wind_speed'].toStringAsFixed(1)} km/h'),
                                _buildWeatherRow('Rain', '${weatherData['rain'].toStringAsFixed(1)} mm/h'),
                                _buildWeatherRow('Cloudiness', '${weatherData['cloudiness']} %'),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4ACDEB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RecommendationPage()),
                            );
                          },
                          child: const Text('View Clothing Recommendation', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildJustArrivedSection(),
                      const SizedBox(height: 20),
                      _buildFashionTrendSection(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildJustArrivedSection() {
    return Card(
      color: const Color(0xFF5E929E),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Just Arrived',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildItemCard('assets/placeholder1.png', 'Sleeve Sweater', '\$29.99'),
                  _buildItemCard('assets/placeholder2.png', 'Pink Dress', '\$29.99'),
                  _buildItemCard('assets/placeholder5.png', 'Leather Jacket', '\$39.99'),
                  _buildItemCard('assets/placeholder6.png', 'Glam glasses', '\$19.99'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFashionTrendSection() {
    return Card(
      color: const Color(0xFF5E929E),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fashion Trend',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildItemCard('assets/placeholder3.png', 'Flamingo Bikini', '\$59.99'),
                _buildItemCard('assets/placeholder4.png', 'Red Fur', '\$400'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(String imagePath, String title, String price) {
    return Container(
      width: 110,
      child: Card(
        color: const Color(0xFFDDEAE0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(imagePath, height: 100, fit: BoxFit.cover),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                price,
                style: const TextStyle(fontSize: 12, color: Color(0xFF007180)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}