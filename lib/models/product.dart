import 'package:flutter/foundation.dart'; 
class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing product JSON: $json');
    try {
      return Product(
        id: json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['imageUrl'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error parsing product JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}