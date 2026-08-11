// lib/models/favorit_model.dart
// Model untuk data dari API sendiri (tabel favorit di Aiven)

class FavoritModel {
  final int id;
  final int idApi;
  final String nama;
  final String image;
  final String? catatan;
  final int? rating;
  final String createdAt;

  FavoritModel({
    required this.id,
    required this.idApi,
    required this.nama,
    required this.image,
    this.catatan,
    this.rating,
    required this.createdAt,
  });

  factory FavoritModel.fromJson(Map<String, dynamic> json) {
    return FavoritModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      idApi: int.tryParse(json['id_api'].toString()) ?? 0,
      nama: json['nama'] ?? '',
      image: json['image'] ?? '',
      catatan: json['catatan'],
      rating: json['rating'] != null
          ? int.tryParse(json['rating'].toString())
          : null,
      createdAt: json['created_at'] ?? '',
    );
  }
}
