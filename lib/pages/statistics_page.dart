import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:outfitaura/viewmodels/statistics_viewmodel.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StatisticsViewModel>(context);

    if (!viewModel.isLoading && viewModel.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(viewModel.errorMessage!),
              ElevatedButton(
                onPressed: () => viewModel.fetchStats(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Most Bought Items',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: viewModel.mostBought.isNotEmpty
                            ? (viewModel.mostBought.map((e) => e['totalQuantity'] as num).reduce((a, b) => a > b ? a : b) + 5).toDouble()
                            : 10.0,
                        barGroups: viewModel.mostBought.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: (item['totalQuantity'] as num).toDouble(),
                                color: Colors.blue,
                                width: 20,
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                return index >= 0 && index < viewModel.mostBought.length
                                    ? Text(viewModel.mostBought[index]['title'] ?? 'Unknown',
                                        style: const TextStyle(color: Colors.black, fontSize: 10))
                                    : const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Gender Percentages',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: viewModel.genderPercentages.map((data) {
                          return PieChartSectionData(
                            value: (data['percentage'] as num).toDouble(),
                            title: '${data['gender']}\n${(data['percentage'] as num).toStringAsFixed(1)}%',
                            color: data['gender'] == 'male' ? Colors.blue : Colors.pink,
                            radius: 50,
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}