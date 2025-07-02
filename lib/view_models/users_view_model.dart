import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../main.dart';

class UsersViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  Future<void> fetchUsers() async {
    isLoading = true;
    errorMessage = null;
    users = []; // Clear stale data
    notifyListeners();
    try {
      users = await ApiService.getUsers();
      debugPrint('UsersViewModel.fetchUsers: $users');
    } catch (e) {
      errorMessage = 'Error fetching users: $e';
      debugPrint(errorMessage);
    }
    isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleUserStatus(String userId, String currentStatus) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('No authentication token found');
      final response = await http.patch(
        Uri.parse('${ApiService.baseUrl}/users/$userId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('toggleUserStatus - Status: ${response.statusCode}, Response: ${response.body}');
      if (response.statusCode == 200) {
        final user = users.firstWhere((u) => u['_id'] == userId);
        user['status'] = currentStatus == 'active' ? 'inactive' : 'active';
        notifyListeners();
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('User status updated to ${user['status']}'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh users to ensure consistency with backend
        await fetchUsers();
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to toggle status');
      }
    } catch (e) {
      errorMessage = 'Error toggling user status: $e';
      debugPrint(errorMessage);
      notifyListeners();
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}