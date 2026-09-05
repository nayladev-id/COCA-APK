// lib/widgets/coffee_card.dart

import 'package:flutter/material.dart';
import '../models/coffee_model.dart';
import '../utils/image_overrides.dart';

class CoffeeCard extends StatelessWidget {
  final CoffeeModel coffee;
  final String? deskripsiId;
  final bool isIced;
  final bool? isFavorit; // Parameter dipertahankan agar tidak memicu error di halaman lain
  final VoidCallback? onFavoritToggle; // Parameter dipertahankan
  final VoidCallback onTap;

  const CoffeeCard({
    super.key,
    required this.coffee,
    this.deskripsiId,
    required this.isIced,
    this.isFavorit,
    this.onFavoritToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Kopi
            SizedBox(
              width: 120,
              height: 120,
              child: ImageOverrides.buildImage(
                title: coffee.title,
                isIced: isIced,
                networkUrl: coffee.image,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.coffee, size: 40, color: Colors.grey),
                ),
              ),
            ),
            // 2. Detail Teks & Harga
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coffee.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deskripsiId ?? coffee.description,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isIced ? 'Rp 28.000' : 'Rp 25.000',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // IKON LOVE (FAVORIT) RESMI DIHILANGKAN DARI KARTU!
            // Sekarang pelanggan hanya bisa menjadikan favorit lewat halaman Detail
          ],
        ),
      ),
    );
  }
}