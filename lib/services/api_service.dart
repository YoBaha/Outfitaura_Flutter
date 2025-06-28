import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:outfitaura/models/clothing_item.dart';
import 'package:outfitaura/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000';
  static const String pythonServerUrl = 'http://10.0.2.2:8000';
  static const String weatherApiUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String weatherApiKey = '54d46cebfb8ef1ed66e6412beea32622';


  static String _parseWeatherCondition(String description, int weatherId) {
    description = description.toLowerCase();
    if (description.contains('clear')) return 'Clear';
    if (description.contains('cloud')) return 'Clouds';
    if (description.contains('drizzle')) return 'Drizzle';
    if (description.contains('mist') || description.contains('fog') || description.contains('haze')) return 'Mist';
    if (description.contains('rain')) return 'Rain';
    if (description.contains('snow') || description.contains('sleet')) return 'Snow';
    if (description.contains('thunderstorm')) return 'Thunderstorm';
    if (weatherId >= 200 && weatherId < 300) return 'Thunderstorm';
    if (weatherId >= 300 && weatherId < 400) return 'Drizzle';
    if (weatherId >= 500 && weatherId < 600) return 'Rain';
    if (weatherId >= 600 && weatherId < 700) return 'Snow';
    if (weatherId >= 700 && weatherId < 800) return 'Mist';
    if (weatherId == 800) return 'Clear';
    if (weatherId > 800) return 'Clouds';
    return 'Clouds';
  }

  static Future<Map<String, dynamic>> getWeather() async {
    try {
      debugPrint('Fetching weather data...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Location permission denied');
      }
      if (permission == LocationPermission.deniedForever) throw Exception('Location permission permanently denied');

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      debugPrint('Position: lat=${position.latitude}, lon=${position.longitude}');

      final url = '$weatherApiUrl?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$weatherApiKey';
      debugPrint('Weather API URL: $url');
      final response = await http.get(Uri.parse(url));

      debugPrint('Weather API response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Weather data: $data');
        final condition = _parseWeatherCondition(data['weather'][0]['description'], data['weather'][0]['id']);
        debugPrint('Parsed condition: $condition');
        final weatherData = {
          'temperature': data['main']['temp'],
          'humidity': data['main']['humidity'],
          'wind_speed': data['wind']['speed'] * 3.6,
          'rain': data['rain']?['1h'] ?? 0.0,
          'cloudiness': data['clouds']['all'],
          'condition': condition,
        };

        await _sendWeatherToPythonServer(weatherData);
        return weatherData;
      } else {
        debugPrint('Weather API error: ${response.body}');
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      rethrow;
    }
  }

  static Future<void> _sendWeatherToPythonServer(Map<String, dynamic> weatherData) async {
    try {
      final response = await http.post(
        Uri.parse('$pythonServerUrl/api/get-recommendation'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(weatherData),
      );
      debugPrint('Python server response: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('Python server error: ${response.body}');
        throw Exception('Failed to send weather data to Python server: ${response.body}');
      }
      final responseData = jsonDecode(response.body);
      debugPrint('Python server recommendation: ${responseData['recommendation']}');
    } catch (e) {
      debugPrint('Error sending weather to Python server: $e');
      throw Exception('Error communicating with Python server: $e');
    }
  }

static Future<String> getRecommendation() async {
  try {
    final token = await getToken();
    for (int i = 0; i < 3; i++) {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recommendation'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      debugPrint('Recommendation response: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recommendation = data['recommendation']?.toString();
        if (recommendation == null || recommendation.isEmpty) {
          throw Exception('Empty recommendation received');
        }
        return recommendation;
      } else if (response.statusCode == 404) {
        debugPrint('Recommendation not available yet: ${response.body}');
        await Future.delayed(const Duration(seconds: 1));
        continue;
      } else {
        debugPrint('Recommendation error: ${response.body}');
        throw Exception('Failed to fetch recommendation: ${response.body}');
      }
    }
    throw Exception('Recommendation not available after retries');
  } catch (e) {
    debugPrint('Error fetching recommendation: $e');
    throw Exception('Error fetching recommendation: $e');
  }
}
static Future<void> uploadClothingItem(String title, XFile image) async {
  try {
    final token = await getToken();
    debugPrint('Uploading with token: $token');
    if (token == null) throw Exception('No authentication token found');
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/wardrobe'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    debugPrint('Sending request to $baseUrl/api/wardrobe with file: ${image.path}');
    final response = await request.send();
    debugPrint('Upload response: ${response.statusCode}');
    if (response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      debugPrint('Upload error: $responseBody');
      throw Exception('Failed to upload clothing item: $responseBody');
    }
  } catch (e) {
    debugPrint('Error uploading clothing item: $e');
    throw Exception('Error uploading clothing item: $e');
  }
}

static Future<List<ClothingItem>> getWardrobe() async {
  try {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/wardrobe'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    debugPrint('Wardrobe response: ${response.statusCode}, Body: ${response.body}'); 
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ClothingItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch wardrobe: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error fetching wardrobe: $e');
    throw Exception('Error fetching wardrobe: $e');
  }
}
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      if (data['user'] != null) {
        await prefs.setString('user', jsonEncode(data['user']));
      }
      return data;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

 static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String confirmPassword,
    int age,
    String gender, 
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'age': age,
        'gender': gender, 
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return data;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Sign-up failed');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    return userData != null ? jsonDecode(userData) : null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<void> deleteClothingItem(String id) async {
  try {
    final token = await getToken();
    debugPrint('Deleting item with id: $id, token: $token');
    if (token == null) throw Exception('No authentication token found');
    final response = await http.delete(
      Uri.parse('$baseUrl/api/wardrobe/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint('Delete response: ${response.statusCode}');
    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);
      debugPrint('Delete error: $responseBody');
      throw Exception('Failed to delete clothing item: ${responseBody['message']}');
    }
  } catch (e) {
    debugPrint('Error deleting clothing item: $e');
    throw Exception('Error deleting clothing item: $e');
  }
}

static Future<void> saveFavoriteOutfit(Map<String, dynamic> outfitData) async {
  try {
    final token = await getToken();
    debugPrint('Saving favorite outfit with token: $token');
    if (token == null) throw Exception('No authentication token found');
    final response = await http.post(
      Uri.parse('$baseUrl/api/favorites'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'items': outfitData['items']}),
    );
    debugPrint('Save favorite response: ${response.statusCode}');
    if (response.statusCode != 201) {
      final responseBody = jsonDecode(response.body);
      debugPrint('Save favorite error: $responseBody');
      throw Exception('Failed to save favorite outfit: ${responseBody['message']}');
    }
  } catch (e) {
    debugPrint('Error saving favorite outfit: $e');
    throw Exception('Error saving favorite outfit: $e');
  }
}

static Future<List<Map<String, dynamic>>> getFavoriteOutfits() async {
  try {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/favorites'),
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint('Get favorites response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => {
        'id': item['_id'],
        'items': (item['items'] as List).map((i) => {
          'type': i['type'],
          'clothingItemId': i['clothingItemId']['_id'],
          'title': i['title'],
          'imageUrl': i['imageUrl'],
          'createdAt': DateTime.parse(i['createdAt']),
        }).toList(),
        'createdAt': DateTime.parse(item['createdAt']),
      }).toList();
    } else {
      debugPrint('Get favorites error: ${response.body}');
      throw Exception('Failed to fetch favorite outfits: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error fetching favorite outfits: $e');
    throw Exception('Error fetching favorite outfits: $e');
  }
}
static Future<List<Product>> getMarketplaceProducts() async {
  try {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/marketplace'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch products: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error fetching products: $e');
  }
}

static Future<void> uploadMarketplaceProduct(String title, String description, double price, XFile image) async {
  try {
    final token = await getToken();
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/marketplace'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    final response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Failed to upload product: ${await response.stream.bytesToString()}');
    }
  } catch (e) {
    throw Exception('Error uploading product: $e');
  }
}

static Future<void> updateMarketplaceProduct(String id, String title, String description, double price, XFile? image) async {
  try {
    final token = await getToken();
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/api/marketplace/$id'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${await response.stream.bytesToString()}');
    }
  } catch (e) {
    throw Exception('Error updating product: $e');
  }
}

static Future<void> deleteMarketplaceProduct(String id) async {
  try {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/marketplace/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error deleting product: $e');
  }
}

}