// lib/utils/image_overrides.dart
// Override gambar untuk semua kopi menggunakan asset lokal.
// Prioritas: asset lokal > URL dari API.

import 'package:flutter/material.dart';

class ImageOverrides {
  // Map nama kopi (title) -> path asset lokal
  // Sesuai nama file yang ada di assets/images/
  static const Map<String, String> _hotAssets = {
    'Latte':              'assets/images/hot/Latte.jpg',
    'Caramel Latte':      'assets/images/hot/Caramel Latte.jpg',
    'Macchiato':          'assets/images/hot/Macchiato.jpg',
    'Classic Cappuccino': 'assets/images/hot/Classic Cappuccino.jpg',
    'Matcha Latte':       'assets/images/hot/Matcha Latte.webp',
    'Svart Te':           'assets/images/hot/Svart Te.jpg',
    'Islatte':            'assets/images/hot/Islatte.jpg',
    'Islatte Mocha':      'assets/images/hot/Islatte Mocha.jpg',
    'Frapino Caramel':    'assets/images/hot/Frapino Caramel.jpg',
    'Frapino Mocka':      'assets/images/hot/Frapino Mocka.jpg',
    'Affogato al Caffè':  'assets/images/hot/Affogato al Caffè.webp',
    'Frozen Lemonade':    'assets/images/hot/Frozen Lemonade.jpg',
    'Flat White':         'assets/images/hot/Flat White.jpg',
    'Caramel Macchiato':  'assets/images/hot/Caramel Macchiato.jpg',
  };

  static const Map<String, String> _icedAssets = {
    'Iced Coffee':   'assets/images/iced/Iced Coffee.jpg',
    'Iced Espresso': 'assets/images/iced/Iced Espresso.jpg',
    'Cold Brew':     'assets/images/iced/Cold Brew.jpg',
    'Frappuccino':   'assets/images/iced/Frappuccino.jpg',
    'Nitro':         'assets/images/iced/Nitro.jpg',
    'Mazagran':      'assets/images/iced/Mazagran.jpg',
  };

  // Gambar kopi lokal/nusantara
  static const Map<String, String> _lokalAssets = {
    'Kopi Tubruk':    'assets/images/lokal/Kopi Tubruk.jpg',
    'Kopi Toraja':    'assets/images/lokal/Kopi Toraja.jpg',
    'Kopi Luwak':     'assets/images/lokal/Kopi Luwak.jpg',
    'Kopi Kintamani': 'assets/images/lokal/Kopi Kintamani.jpg',
    'Kopi Gayo':      'assets/images/lokal/Kopi Gayo.jpg',
  };

  /// Kembalikan path asset lokal jika ada, null jika tidak ada.
  static String? getLocalAsset({required String title, required bool isIced}) {
    // Cek kopi lokal/nusantara dulu (nama unik, tidak bentrok)
    if (_lokalAssets.containsKey(title)) return _lokalAssets[title];
    return isIced ? _icedAssets[title] : _hotAssets[title];
  }

  /// Cek apakah gambar lokal tersedia untuk kopi ini.
  static bool hasLocalImage({required String title, required bool isIced}) {
    final asset = getLocalAsset(title: title, isIced: isIced);
    return asset != null;
  }

  /// Widget gambar yang otomatis memilih antara asset lokal atau network.
  static Widget buildImage({
    required String title,
    required bool isIced,
    required String networkUrl,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    final localAsset = getLocalAsset(title: title, isIced: isIced);

    if (localAsset != null) {
      return Image.asset(
        localAsset,
        fit: fit,
        errorBuilder: (_, __, ___) => errorWidget ??
            const Icon(Icons.coffee, size: 48),
      );
    }

    // Fallback ke network jika tidak ada asset lokal
    if (networkUrl.isNotEmpty) {
      return Image.network(
        networkUrl,
        fit: fit,
        errorBuilder: (_, __, ___) => errorWidget ??
            const Icon(Icons.coffee, size: 48),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }

    return errorWidget ?? const Icon(Icons.coffee, size: 48);
  }
}
