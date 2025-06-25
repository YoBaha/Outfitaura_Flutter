class ClothingItem {
  final String id;
  final String title;
  final String imageUrl;
  final DateTime createdAt;

  ClothingItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['_id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}