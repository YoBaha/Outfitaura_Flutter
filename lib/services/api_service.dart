import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/stats.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // Update for production

  static Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return {'user': User.fromJson(data['user']), 'message': data['message']};
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<List<Product>> getProducts() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/marketplace'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch products');
    }
  }

  static Future<void> uploadMarketplaceProduct(String title, String description, double price, XFile image) async {
    final token = await getToken();
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/marketplace'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();

    if (kIsWeb) {
      // Web: Use bytes from XFile
      final bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: image.name,
      ));
    } else {
      // Mobile: Use file path
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Failed to upload product: ${await response.stream.bytesToString()}');
    }
  }

  static Future<void> updateMarketplaceProduct(String id, String title, String description, double price, XFile? image) async {
    final token = await getToken();
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/marketplace/$id'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();

    if (image != null) {
      if (kIsWeb) {
        // Web: Use bytes from XFile
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name,
        ));
      } else {
        // Mobile: Use file path
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${await response.stream.bytesToString()}');
    }
  }

  static Future<void> deleteMarketplaceProduct(String id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/marketplace/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }

  static Future<Stats> getStats() async {
    final token = await getToken();
    final mostBoughtResponse = await http.get(
      Uri.parse('$baseUrl/stats/most-bought'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final genderPercentagesResponse = await http.get(
      Uri.parse('$baseUrl/stats/gender-percentages'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (mostBoughtResponse.statusCode == 200 && genderPercentagesResponse.statusCode == 200) {
      final mostBought = jsonDecode(mostBoughtResponse.body) as List<dynamic>;
      final genderPercentages = jsonDecode(genderPercentagesResponse.body) as List<dynamic>;
      return Stats.fromJson(
        mostBought: mostBought,
        genderPercentages: genderPercentages,
      );
    } else {
      throw Exception('Failed to fetch stats: ${mostBoughtResponse.body}');
    }
  }
}