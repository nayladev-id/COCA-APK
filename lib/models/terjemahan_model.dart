// lib/models/terjemahan_model.dart
// Model untuk data dari API sendiri (tabel terjemahan_kopi di Aiven)

class TerjemahanModel {
  final int id;
  final int idApi;
  final String namaAsli;
  final String deskripsiId;
  final String createdAt;

  TerjemahanModel({
    required this.id,
    required this.idApi,
    required this.namaAsli,
    required this.deskripsiId,
    required this.createdAt,
  });

  factory TerjemahanModel.fromJson(Map<String, dynamic> json) {
    return TerjemahanModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      idApi: int.tryParse(json['id_api'].toString()) ?? 0,
      namaAsli: json['nama_asli'] ?? '',
      deskripsiId: json['deskripsi_id'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
