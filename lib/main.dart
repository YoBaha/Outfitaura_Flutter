import 'package:flutter/material.dart';
import 'package:outfitaura_admin_web/views/feedback_page.dart';
import 'package:provider/provider.dart';
import 'views/login_page.dart';
import 'views/home_page.dart';
import 'views/marketplace_page.dart';
import 'views/stats_page.dart';
import 'view_models/auth_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'OutfitAura Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF007180),
          scaffoldBackgroundColor: const Color(0xFFDDEAE0),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ACDEB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/marketplace': (context) => const MarketplacePage(),
          '/feedback': (context) => const FeedbackPage(),
          '/stats': (context) => const StatsPage(),
        },
      ),
    );
  }
}