import 'package:flutter/material.dart';
import '../models/stats.dart';
import '../services/api_service.dart';

class StatsViewModel with ChangeNotifier {
  Stats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  Stats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await ApiService.getStats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }
}