import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UsersViewModel with ChangeNotifier {
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  String? errorMessage;
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  Future<void> fetchUsers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allUsers = await ApiService.getUsers();
      _updateFilteredUsers();
      debugPrint('Fetched users: $_allUsers');
    } catch (e) {
      errorMessage = 'Error fetching users: $e';
      debugPrint('Error in fetchUsers: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _updateFilteredUsers();
    notifyListeners();
  }

  void _updateFilteredUsers() {
    if (_searchQuery.isEmpty) {
      users = _allUsers;
    } else {
      users = _allUsers.where((user) {
        final name = user['name']?.toString().toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }
}