import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../view_models/stats_view_model.dart';
import '../widgets/sidebar.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen height for responsive chart sizing
    final screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (_) => StatsViewModel()..fetchStats(),
      child: Consumer<StatsViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: Row(
              children: [
                const Sidebar(),
                Expanded(
                  child: Container(
                    color: const Color(0xFFDDEAE0),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statistics Dashboard',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF007180),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Refresh Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4ACDEB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                viewModel.fetchStats();
                              },
                              child: const Text('Refresh Charts'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (viewModel.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (viewModel.errorMessage != null)
                            Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(
                                  color: Color(0xFFE15757), fontSize: 16),
                            )
                          else if (viewModel.stats != null) ...[
                            // Most Bought Items Bar Chart
                            const Text(
                              'Most Bought Items',
                              style: TextStyle(
                                  fontSize: 20, color: Color(0xFF007180)),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: screenHeight * 0.3, // Responsive height
                              child: BarChart(
                                BarChartData(
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index <
                                              viewModel.stats!.mostBought.length) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Text(
                                                viewModel
                                                    .stats!.mostBought[index].title,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                        reservedSize: 40,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true, reservedSize: 40),
                                    ),
                                  ),
                                  barGroups: viewModel.stats!.mostBought
                                      .asMap()
                                      .entries
                                      .map((entry) => BarChartGroupData(
                                            x: entry.key,
                                            barRods: [
                                              BarChartRodData(
                                                toY: entry.value.totalQuantity
                                                    .toDouble(),
                                                color: const Color(0xFF4ACDEB),
                                                width: 20,
                                              ),
                                            ],
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Gender Percentages Pie Chart
                            const Text(
                              'Gender Distribution',
                              style: TextStyle(
                                  fontSize: 20, color: Color(0xFF007180)),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: screenHeight * 0.3, // Responsive height
                              child: PieChart(
                                PieChartData(
                                  sections: viewModel.stats!.genderPercentages
                                      .map((item) => PieChartSectionData(
                                            value: item.percentage,
                                            title:
                                                '${item.gender}\n${item.percentage.toStringAsFixed(1)}%',
                                            color: item.gender == 'male'
                                                ? const Color(0xFF007180)
                                                : const Color(0xFF82BECC),
                                            radius: 100,
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20), // Extra padding at bottom
                        ],
                      ),
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
}