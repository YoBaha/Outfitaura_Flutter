import 'package:flutter/material.dart';
import 'package:outfitaura/pages/cart_page.dart';
import 'package:outfitaura/viewmodels/cart_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:outfitaura/pages/home_page.dart';
import 'package:outfitaura/pages/marketplace_page.dart';
import 'package:outfitaura/pages/selection_page.dart';
import 'package:outfitaura/pages/login_page.dart';
import 'package:outfitaura/pages/wardrobe_page.dart';
import 'package:outfitaura/pages/recommendation_page.dart';
import 'package:outfitaura/pages/favorites_page.dart';
import 'package:outfitaura/viewmodels/wardrobe_viewmodel.dart';
import 'package:outfitaura/viewmodels/marketplace_viewmodel.dart'; // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WardrobeViewModel()..fetchWardrobe()), // Existing provider
        ChangeNotifierProvider(create: (_) => MarketplaceViewModel()..fetchProducts()), // Add this provider
        ChangeNotifierProvider(create: (_) => CartViewModel()..fetchCart()), // Add this provider
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