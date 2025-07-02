import 'package:flutter/material.dart';
import 'package:outfitaura_admin_web/services/api_service.dart';
import '../models/feedback.dart' as CustomFeedback;

enum SortMode { none, ratingDesc, dateNewest, dateOldest }

class FeedbackViewModel extends ChangeNotifier {
  List<CustomFeedback.Feedback> _allFeedback = [];
  List<CustomFeedback.Feedback> feedbackList = [];
  Map<String, dynamic>? feedbackStats;
  bool isLoading = false;
  String? errorMessage;
  SortMode _sortMode = SortMode.none;

  SortMode get sortMode => _sortMode;

  Future<void> fetchFeedback() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allFeedback = await ApiService.getFeedback();
      feedbackStats = await ApiService.getFeedbackStats();
      _updateSortedFeedback();
      debugPrint('Fetched feedback: $_allFeedback');
    } catch (e) {
      errorMessage = 'Error fetching feedback: $e';
      debugPrint('Error in fetchFeedback: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void sortFeedback(SortMode mode) {
    _sortMode = mode;
    _updateSortedFeedback();
    notifyListeners();
  }

  void _updateSortedFeedback() {
    feedbackList = List.from(_allFeedback);
    switch (_sortMode) {
      case SortMode.ratingDesc:
        feedbackList.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortMode.dateNewest:
        feedbackList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortMode.dateOldest:
        feedbackList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortMode.none:
        // No sorting, use original order
        break;
    }
  }
}