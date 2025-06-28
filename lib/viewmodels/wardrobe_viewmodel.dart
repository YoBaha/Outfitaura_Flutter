import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outfitaura/models/clothing_item.dart';
import 'package:outfitaura/services/api_service.dart';
import 'package:outfitaura/pages/wardrobe_page.dart';

class WardrobeViewModel extends ChangeNotifier {
  List<ClothingItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  Future<void>? _fetchFuture; // Cache the future

  List<ClothingItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Future<void> get fetchFuture => _fetchFuture ??= fetchWardrobe(); // Lazy initialization

  WardrobeViewModel() {
    _fetchFuture = fetchWardrobe(); // Initialize on creation
  }

  Future<void> fetchWardrobe() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await ApiService.getWardrobe();
      debugPrint('Fetched wardrobe items: ${_items.map((i) => '${i.title} (ID: ${i.id})').join(', ')}');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Fetch error: $_errorMessage');
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
      final trimmedTitle = title.trim();
      debugPrint('Uploading item with title: "$trimmedTitle"');
      await ApiService.uploadClothingItem(trimmedTitle, image);
      await fetchWardrobe();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Upload error: $_errorMessage');
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