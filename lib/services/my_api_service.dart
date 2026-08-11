// lib/services/my_api_service.dart
// Service untuk komunikasi ke REST API Coffee Catalog di VPS

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/terjemahan_model.dart';
import '../models/favorit_model.dart';
import '../utils/auth_manager.dart';

class MyApiService {
  // Base URL API — Vercel Proxy ke VPS (agar support HTTPS di Web)
  static const String _baseUrl =
      'https://coca-neon.vercel.app/api';

  // =================================================
  // AUTHENTICATION ENDPOINTS
  // =================================================
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth.php?action=login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 15));
      
      final body = json.decode(response.body);
      if (body['status'] == true || body['status'] == 'success') {
        await AuthManager.saveUser(body['user_id'], body['username']);
      }
      return body;
    } catch (e) {
      return {'status': false, 'message': 'Gagal terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth.php?action=register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 15));
      
      final body = json.decode(response.body);
      if (body['status'] == true || body['status'] == 'success') {
        await AuthManager.saveUser(body['user_id'], body['username']);
      }
      return body;
    } catch (e) {
      return {'status': false, 'message': 'Gagal terhubung ke server.'};
    }
  }

  // =================================================
  // TERJEMAHAN ENDPOINTS
  // =================================================

  // GET semua data terjemahan
  Future<List<TerjemahanModel>> fetchAllTerjemahan() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/terjemahan.php'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          final List<dynamic> data = body['data'] ?? [];
          return data.map((e) => TerjemahanModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // GET terjemahan berdasarkan id_api (fallback null jika tidak ada)
  Future<TerjemahanModel?> fetchTerjemahanByIdApi(int idApi) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/terjemahan.php?id=$idApi'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success' && body['data'] != null) {
          return TerjemahanModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // =================================================
  // FAVORIT ENDPOINTS
  // =================================================

  // GET semua favorit
  Future<List<FavoritModel>> fetchAllFavorit() async {
    try {
      final userId = await AuthManager.getUserId() ?? 0;
      final response = await http
          .get(Uri.parse('$_baseUrl/favorit.php?user_id=$userId'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          final List<dynamic> data = body['data'] ?? [];
          return data.map((e) => FavoritModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // POST tambah favorit baru
  // Return: true jika berhasil, false jika gagal
  Future<bool> addFavorit({
    required int idApi,
    required String nama,
    required String image,
  }) async {
    try {
      final userId = await AuthManager.getUserId() ?? 0;
      final response = await http
          .post(
            Uri.parse('$_baseUrl/favorit.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'user_id': userId,
              'id_api': idApi,
              'nama': nama,
              'image': image,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = json.decode(response.body);
      return body['status'] == 'success';
    } catch (_) {
      return false;
    }
  }

  // PUT update catatan & rating favorit
  // Return: true jika berhasil, false jika gagal
  Future<bool> updateFavorit({
    required int id,
    String? catatan,
    int? rating,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/favorit.php?id=$id'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'catatan': catatan,
              'rating': rating,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = json.decode(response.body);
      return body['status'] == 'success';
    } catch (_) {
      return false;
    }
  }

  // DELETE hapus favorit berdasarkan id
  // Return: true jika berhasil, false jika gagal
  Future<bool> deleteFavorit(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/favorit.php?id=$id'))
          .timeout(const Duration(seconds: 15));

      final body = json.decode(response.body);
      return body['status'] == 'success';
    } catch (_) {
      return false;
    }
  }

  // Cek apakah sebuah kopi (by id_api) sudah ada di favorit
  Future<int?> getFavoritId(int idApi) async {
    final list = await fetchAllFavorit();
    for (final f in list) {
      if (f.idApi == idApi) return f.id;
    }
    return null;
  }
}
