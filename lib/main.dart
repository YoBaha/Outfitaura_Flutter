import 'package:flutter/material.dart';
import 'package:outfitaura/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:outfitaura/viewmodels/wardrobe_viewmodel.dart';
import 'package:outfitaura/pages/login_page.dart';
import 'package:outfitaura/pages/wardrobe_page.dart';
import 'package:outfitaura/pages/recommendation_page.dart';
import 'package:outfitaura/pages/favorites_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WardrobeViewModel()..fetchWardrobe(), // Initialize wardrobe data
      child: MaterialApp(
        title: 'OutfitAura',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
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
            case '/cart':
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Page not implemented yet')),
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