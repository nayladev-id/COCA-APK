// lib/services/coffee_api_service.dart
// Service untuk mengambil data kopi dari Sample APIs Coffee (API eksternal)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coffee_model.dart';

class CoffeeApiService {
  static const String _baseUrl = 'https://api.sampleapis.com/coffee';

  // Fetch kopi panas (hot)
  Future<List<CoffeeModel>> fetchHotCoffee() async {
    return await _fetchCoffee('$_baseUrl/hot');
  }

  // Fetch kopi dingin (iced)
  Future<List<CoffeeModel>> fetchIcedCoffee() async {
    return await _fetchCoffee('$_baseUrl/iced');
  }

  // Fetch Kopi Nusantara (API Lokal/GitHub)
  Future<List<CoffeeModel>> fetchKopiNusantara() async {
    return await _fetchCoffee('https://raw.githubusercontent.com/240103042-cmd/Coffe-Cataloge/main/kopi_nusantara.json');
  }

  Future<List<CoffeeModel>> _fetchCoffee(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => CoffeeModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Gagal mengambil data kopi. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Koneksi gagal: $e');
    }
  }
}
