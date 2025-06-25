import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outfitaura/models/clothing_item.dart';
import 'package:outfitaura/services/api_service.dart';
import 'package:outfitaura/pages/wardrobe_page.dart';

class WardrobeViewModel extends ChangeNotifier {
  List<ClothingItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ClothingItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWardrobe() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await ApiService.getWardrobe();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadClothingItem(String title, XFile image) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.uploadClothingItem(title, image);
      await fetchWardrobe(); // Refresh wardrobe after upload
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteClothingItem(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.deleteClothingItem(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}