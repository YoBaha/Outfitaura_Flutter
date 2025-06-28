class Stats {
  final List<MostBoughtItem> mostBought;
  final List<GenderPercentage> genderPercentages;

  Stats({required this.mostBought, required this.genderPercentages});

  factory Stats.fromJson({
    required List<dynamic> mostBought,
    required List<dynamic> genderPercentages,
  }) {
    return Stats(
      mostBought: mostBought
          .map((item) => MostBoughtItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      genderPercentages: genderPercentages
          .map((item) => GenderPercentage.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MostBoughtItem {
  final String id;
  final String title;
  final int totalQuantity;
  final String imageUrl;

  MostBoughtItem({
    required this.id,
    required this.title,
    required this.totalQuantity,
    required this.imageUrl,
  });

  factory MostBoughtItem.fromJson(Map<String, dynamic> json) {
    return MostBoughtItem(
      id: json['_id'] as String,
      title: json['title'] as String,
      totalQuantity: json['totalQuantity'] as int,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}

class GenderPercentage {
  final String gender;
  final double percentage;

  GenderPercentage({required this.gender, required this.percentage});

  factory GenderPercentage.fromJson(Map<String, dynamic> json) {
    return GenderPercentage(
      gender: json['gender'] as String? ?? 'Unknown',
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}