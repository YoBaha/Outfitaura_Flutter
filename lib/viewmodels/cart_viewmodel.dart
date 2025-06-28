import 'package:flutter/material.dart';
import 'package:outfitaura/models/cart.dart';
import 'package:outfitaura/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartViewModel extends ChangeNotifier {
  List<CartItem> _items = [];
  double _totalPrice = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get items => _items;
  double get totalPrice => _totalPrice;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

Future<void> fetchCart() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final token = await ApiService.getToken();
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/api/cart'),
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint('Cart response: ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('items')) {
        final cart = Cart.fromJson(data);
        _items = cart.items;
        _totalPrice = cart.totalPrice;
      } else {
        throw Exception('Invalid cart data format: Missing required fields');
      }
    } else {
      throw Exception('Failed to fetch cart: ${response.body}');
    }
  } catch (e) {
    _errorMessage = e.toString().replaceFirst('Exception: ', '');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> addToCart(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await ApiService.getToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/cart'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'productId': productId}),
      );
      if (response.statusCode == 201) {
        await fetchCart(); 
      } else {
        throw Exception('Failed to add to cart: ${response.body}');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCartItem(String itemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await ApiService.getToken();
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/api/cart/$itemId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        await fetchCart(); 
      } else {
        throw Exception('Failed to delete item: ${response.body}');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}