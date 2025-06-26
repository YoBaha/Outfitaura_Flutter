import 'package:outfitaura/models/product.dart';

class CartItem {
  final String id;
  final String productId; // Should be the _id of the product
  final String title;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

factory CartItem.fromJson(Map<String, dynamic> json) {
  return CartItem(
    id: json['_id'] as String? ?? '',
    productId: json['productId'] != null
        ? (json['productId'] is Map<String, dynamic>
            ? json['productId']['_id'] as String? ?? ''
            : json['productId'] as String? ?? '')
        : '',
    title: json['title'] as String? ?? 'Unknown',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['imageUrl'] as String? ?? '',
    quantity: json['quantity'] as int? ?? 1,
  );
}

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }
}

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['_id'] as String? ?? '', // Handle null _id
      userId: json['userId'] as String,
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}