import 'package:flutter/material.dart';
import '../models/stats.dart';
import '../services/api_service.dart';

class StatsViewModel with ChangeNotifier {
  Stats? _stats;
  Map<String, dynamic>? _feedbackStats;
  bool _isLoading = false;
  String? _errorMessage;

  Stats? get stats => _stats;
  Map<String, dynamic>? get feedbackStats => _feedbackStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await ApiService.getStats();
      _feedbackStats = await ApiService.getFeedbackStats();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }
}