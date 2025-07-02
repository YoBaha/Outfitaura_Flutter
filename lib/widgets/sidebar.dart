import 'package:flutter/material.dart';
import 'package:outfitaura_admin_web/services/api_service.dart';
import 'package:outfitaura_admin_web/views/login_page.dart';
import '../views/home_page.dart';
import '../views/marketplace_page.dart';
import '../views/stats_page.dart';
import '../views/feedback_page.dart'; 

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF007180),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Image.asset('assets/logo.png', height: 80),
          const Text(
            'OUTFITAURA ADMIN',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
              (Route<dynamic> route) => false,
            ),
          ),
          ListTile(
            title: const Text('Marketplace', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const MarketplacePage())),
          ),
          ListTile(
            title: const Text('Statistics', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const StatsPage())),
          ),
          ListTile(
            title: const Text('Feedback', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const FeedbackPage())),
          ),
          ListTile(
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () async {
              await ApiService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()), // Adjust path
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}