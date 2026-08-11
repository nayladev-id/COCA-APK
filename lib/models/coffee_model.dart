// lib/models/coffee_model.dart
// Model untuk data dari Sample APIs Coffee (https://api.sampleapis.com/coffee/hot atau /iced)

class CoffeeModel {
  final int id;
  final String title;
  final String description;
  final List<String> ingredients;
  final String image;

  CoffeeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.image,
  });

  factory CoffeeModel.fromJson(Map<String, dynamic> json) {
    // ingredients bisa berupa List ATAU String dari API eksternal
    List<String> parseIngredients(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      if (raw is String) return raw.isNotEmpty ? [raw] : [];
      return [];
    }

    return CoffeeModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      ingredients: parseIngredients(json['ingredients']),
      image: json['image'] ?? '',
    );
  }
}
