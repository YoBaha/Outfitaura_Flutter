import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:outfitaura_admin_web/views/feedback_page.dart';
import 'package:outfitaura_admin_web/views/login_page.dart';
import 'package:outfitaura_admin_web/views/home_page.dart';
import 'package:outfitaura_admin_web/views/marketplace_page.dart';
import 'package:outfitaura_admin_web/views/stats_page.dart';
import 'package:outfitaura_admin_web/views/users_page.dart'; // Add UsersPage import
import 'package:outfitaura_admin_web/view_models/auth_view_model.dart';
import 'package:outfitaura_admin_web/view_models/users_view_model.dart';
import 'package:outfitaura_admin_web/view_models/dashboard_view_model.dart';

final navigatorKey = GlobalKey<NavigatorState>(); // Add navigatorKey

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
        ChangeNotifierProvider(create: (_) => UsersViewModel()), // Add UsersViewModel
        ChangeNotifierProvider(create: (_) => DashboardViewModel()), // Add DashboardViewModel
      ],
      child: MaterialApp(
        title: 'OutfitAura Admin',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // Add navigatorKey for ScaffoldMessenger
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
          '/users': (context) => const UsersPage(), 
        },
      ),
    );
  }
}