import 'package:flutter/material.dart';
import 'package:outfitaura/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StatisticsViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _mostBought = [];
  List<Map<String, dynamic>> _genderPercentages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get mostBought => _mostBought;
  List<Map<String, dynamic>> get genderPercentages => _genderPercentages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await ApiService.getToken();
      final [mostBoughtResponse, genderResponse] = await Future.wait([
        http.get(
          Uri.parse('${ApiService.baseUrl}/api/stats/most-bought'),
          headers: {'Authorization': 'Bearer $token'},
        ),
        http.get(
          Uri.parse('${ApiService.baseUrl}/api/stats/gender-percentages'),
          headers: {'Authorization': 'Bearer $token'},
        ),
      ]);

      if (mostBoughtResponse.statusCode == 200) {
        _mostBought = List<Map<String, dynamic>>.from(jsonDecode(mostBoughtResponse.body));
      } else {
        throw Exception('Failed to fetch most bought items: ${mostBoughtResponse.body}');
      }

      if (genderResponse.statusCode == 200) {
        _genderPercentages = List<Map<String, dynamic>>.from(jsonDecode(genderResponse.body));
      } else {
        throw Exception('Failed to fetch gender percentages: ${genderResponse.body}');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}