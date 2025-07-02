class ClothingItem {
  final String id; 
  final String userId; 
  final String title;
  final String imageUrl;
  final DateTime createdAt;

  ClothingItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['_id'] as String, 
      userId: json['userId'] as String, 
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}