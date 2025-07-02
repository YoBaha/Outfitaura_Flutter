import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/dashboard_view_model.dart';
import '../views/feedback_page.dart';
import '../views/login_page.dart';
import '../views/marketplace_page.dart';
import '../views/stats_page.dart';
import '../views/users_page.dart';
import '../widgets/sidebar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()..fetchCounts()),
      ],
      child: Consumer2<AuthViewModel, DashboardViewModel>(
        builder: (context, authViewModel, dashboardViewModel, _) {
          return Scaffold(
            body: Row(
              children: [
                const Sidebar(),
                Expanded(
                  child: Container(
                    color: const Color(0xFFDDEAE0),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to OutfitAura Admin Dashboard',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF007180),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (dashboardViewModel.isLoading)
                          const Center(child: CircularProgressIndicator(color: Color(0xFF007180)))
                        else if (dashboardViewModel.errorMessage != null)
                          Text(
                            dashboardViewModel.errorMessage!,
                            style: const TextStyle(color: Color(0xFFE15757), fontSize: 16),
                          )
                        else
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.5,
                              children: [
                                _buildDashboardCard(
                                  context,
                                  icon: Icons.people,
                                  title: 'Total Users',
                                  value: dashboardViewModel.totalUsers?.toString() ?? 'N/A',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const UsersPage()),
                                    );
                                  },
                                ),
                                _buildDashboardCard(
                                  context,
                                  icon: Icons.store,
                                  title: 'Total Products',
                                  value: dashboardViewModel.totalProducts?.toString() ?? 'N/A',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const MarketplacePage()),
                                    );
                                  },
                                ),
                                _buildDashboardCard(
                                  context,
                                  icon: Icons.bar_chart,
                                  title: 'View Statistics',
                                  value: '',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const StatsPage()),
                                    );
                                  },
                                ),
                                _buildDashboardCard(
                                  context,
                                  icon: Icons.feedback,
                                  title: 'View Feedback',
                                  value: '',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const FeedbackPage()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4ACDEB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              await authViewModel.logout();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: const Text('Logout', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String title, required String value, required VoidCallback onTap}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFF82BECC),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}