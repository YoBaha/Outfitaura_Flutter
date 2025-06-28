import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outfitaura/models/product.dart';
import 'package:outfitaura/services/api_service.dart';

class MarketplaceViewModel extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await ApiService.getMarketplaceProducts();
      debugPrint('Fetched products: ${_products.map((p) => p.title).join(', ')}');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Fetch error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadProduct(String title, String description, double price, XFile image) async {
    if (_errorMessage != null) return; 
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.uploadMarketplaceProduct(title, description, price, image);
      await fetchProducts(); 
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(String id, String title, String description, double price, XFile? image) async {
    if (_errorMessage != null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.updateMarketplaceProduct(id, title, description, price, image);
      await fetchProducts();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    if (_errorMessage != null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.deleteMarketplaceProduct(id);
      _products.removeWhere((product) => product.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}