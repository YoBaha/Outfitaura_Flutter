import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardViewModel with ChangeNotifier {
  int? totalUsers;
  int? totalProducts;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchCounts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final counts = await ApiService.getDashboardCounts();
      totalUsers = counts['totalUsers'];
      totalProducts = counts['totalProducts'];
    } catch (e) {
      errorMessage = 'Error fetching counts: $e';
    }

    isLoading = false;
    notifyListeners();
  }
}