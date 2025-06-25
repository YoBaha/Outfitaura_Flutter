import 'package:flutter/material.dart';
import 'package:outfitaura/pages/login_page.dart';
import 'package:outfitaura/pages/wardrobe_page.dart';
import 'package:outfitaura/pages/recommendation_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OutfitAura',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/wardrobe':
            return MaterialPageRoute(builder: (_) => const WardrobePage());
          case '/marketplace':
          case '/cart':
          case '/favorites':
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
    );
  }
}