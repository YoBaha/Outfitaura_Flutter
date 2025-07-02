import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/feedback_view_model.dart';
import '../widgets/sidebar.dart';
import '../models/feedback.dart' as CustomFeedback;

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedbackViewModel()..fetchFeedback(),
      child: Scaffold(
        body: Row(
          children: [
            const Sidebar(),
            Expanded(
              child: Container(
                color: const Color(0xFFDDEAE0),
                padding: const EdgeInsets.all(16.0),
                child: Consumer<FeedbackViewModel>(
                  builder: (context, viewModel, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Feedback',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007180),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sort Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildSortButton(
                              context,
                              viewModel,
                              text: 'Sort by Rating (High to Low)',
                              mode: SortMode.ratingDesc,
                            ),
                            const SizedBox(width: 10),
                            _buildSortButton(
                              context,
                              viewModel,
                              text: 'Sort by Date (Newest)',
                              mode: SortMode.dateNewest,
                            ),
                            const SizedBox(width: 10),
                            _buildSortButton(
                              context,
                              viewModel,
                              text: 'Sort by Date (Oldest)',
                              mode: SortMode.dateOldest,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (viewModel.isLoading)
                          const Center(child: CircularProgressIndicator(color: Color(0xFF007180)))
                        else if (viewModel.errorMessage != null)
                          Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(color: Color(0xFFE15757), fontSize: 16),
                          )
                        else ...[
                          // Feedback Stats Summary
                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            color: const Color(0xFF82BECC),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Average Rating: ${viewModel.feedbackStats != null ? viewModel.feedbackStats!['averageRating'].toStringAsFixed(1) : 'N/A'}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  Text(
                                    'Total Feedback: ${viewModel.feedbackStats != null ? viewModel.feedbackStats!['totalFeedback'] : 0}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (viewModel.feedbackList.isEmpty)
                            const Text(
                              'No feedback available',
                              style: TextStyle(color: Color(0xFF007180), fontSize: 16),
                            )
                          else
                            Expanded(
                              child: SingleChildScrollView(
                                child: Card(
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(
                                          label: Text('Username',
                                              style:
                                                  TextStyle(color: Color(0xFF007180)))),
                                      DataColumn(
                                          label: Text('Rating',
                                              style:
                                                  TextStyle(color: Color(0xFF007180)))),
                                      DataColumn(
                                          label: Text('Message',
                                              style:
                                                  TextStyle(color: Color(0xFF007180)))),
                                      DataColumn(
                                          label: Text('Date',
                                              style:
                                                  TextStyle(color: Color(0xFF007180)))),
                                    ],
                                    rows: viewModel.feedbackList.map((feedback) {
                                      return DataRow(cells: [
                                        DataCell(Text(feedback.username ?? 'N/A')),
                                        DataCell(Row(
                                          children: List.generate(
                                            5,
                                            (index) => Icon(
                                              index < feedback.rating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.yellow,
                                              size: 20,
                                            ),
                                          ),
                                        )),
                                        DataCell(Text(feedback.message ?? 'N/A')),
                                        DataCell(Text(feedback.createdAt
                                                ?.toLocal()
                                                .toString()
                                                .split('.')[0] ??
                                            'N/A')),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(
      BuildContext context, FeedbackViewModel viewModel, {required String text, required SortMode mode}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: viewModel.sortMode == mode ? const Color(0xFF4ACDEB) : const Color(0xFF82BECC),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: () {
        viewModel.sortFeedback(mode);
      },
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}