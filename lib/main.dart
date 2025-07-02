import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:outfitaura/pages/home_page.dart';
import 'package:outfitaura/pages/marketplace_page.dart';
import 'package:outfitaura/pages/selection_page.dart';
import 'package:outfitaura/pages/login_page.dart';
import 'package:outfitaura/pages/wardrobe_page.dart';
import 'package:outfitaura/pages/recommendation_page.dart';
import 'package:outfitaura/pages/favorites_page.dart';
import 'package:outfitaura/pages/cart_page.dart';
import 'package:outfitaura/pages/statistics_page.dart';
import 'package:outfitaura/viewmodels/wardrobe_viewmodel.dart';
import 'package:outfitaura/viewmodels/marketplace_viewmodel.dart';
import 'package:outfitaura/viewmodels/cart_viewmodel.dart';
import 'package:outfitaura/viewmodels/statistics_viewmodel.dart';
import 'package:outfitaura/services/api_service.dart';
import 'package:outfitaura/pages/outfit_planner_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WardrobeViewModel()..fetchWardrobe()),
        ChangeNotifierProvider(create: (_) => MarketplaceViewModel()..fetchProducts()),
        ChangeNotifierProvider(create: (_) => CartViewModel()..fetchCart()),
        ChangeNotifierProvider(create: (_) => StatisticsViewModel()..fetchStats()),
      ],
      child: MaterialApp(
        title: 'OutfitAura',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LoginPage(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomePage());
            case '/wardrobe':
              return MaterialPageRoute(builder: (_) => const WardrobePage());
            case '/recommendation':
              return MaterialPageRoute(builder: (_) => const RecommendationPage());
            case '/favorites':
              return MaterialPageRoute(builder: (_) => const FavoritesPage());
            case '/marketplace':
              return MaterialPageRoute(builder: (_) => const MarketplacePage());
            case '/cart':
              return MaterialPageRoute(builder: (_) => const CartPage());
            case '/planner': 
              return MaterialPageRoute(builder: (_) => const OutfitPlannerPage());
            case '/statistics':
              return MaterialPageRoute(
                builder: (context) => FutureBuilder<Map<String, dynamic>?>(
                  future: ApiService.getUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data?['role'] != 'admin') {
                      return const Scaffold(
                        body: Center(child: Text('Access Denied')),
                      );
                    }
                    return const StatisticsPage();
                  },
                ),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Route not found')),
                ),
              );
          }
        },
      ),
    );
  }
}