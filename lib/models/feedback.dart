class Feedback {
  final String id;
  final String username;
  final int rating;
  final String message;
  final DateTime createdAt;

  Feedback({
    required this.id,
    required this.username,
    required this.rating,
    required this.message,
    required this.createdAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['_id'],
      username: json['username'],
      rating: json['rating'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}