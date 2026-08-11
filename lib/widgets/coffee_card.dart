// lib/widgets/coffee_card.dart
// Komponen kartu kopi yang reusable — dipakai di HomeScreen

import 'package:flutter/material.dart';
import '../models/coffee_model.dart';
import '../utils/image_overrides.dart';

class CoffeeCard extends StatelessWidget {
  final CoffeeModel coffee;
  final String? deskripsiId;   // dari API sendiri, bisa null jika belum ada terjemahan
  final bool isFavorit;
  final bool isIced;
  final VoidCallback onTap;
  final VoidCallback onFavoritToggle;

  const CoffeeCard({
    super.key,
    required this.coffee,
    this.deskripsiId,
    required this.isFavorit,
    required this.isIced,
    required this.onTap,
    required this.onFavoritToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar kopi
            SizedBox(
              width: 110,
              height: 110,
              child: ImageOverrides.buildImage(
                title: coffee.title,
                isIced: isIced,
                networkUrl: coffee.image,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.coffee,
                      size: 48, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            // Konten teks
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coffee.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // Tampilkan deskripsi Indonesia jika ada, fallback ke deskripsi asli
                      deskripsiId != null && deskripsiId!.isNotEmpty
                          ? deskripsiId!
                          : coffee.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            // Tombol favorit
            IconButton(
              icon: Icon(
                isFavorit ? Icons.favorite : Icons.favorite_border,
                color: isFavorit ? Colors.red : colorScheme.onSurfaceVariant,
              ),
              onPressed: onFavoritToggle,
              tooltip: isFavorit ? 'Hapus dari favorit' : 'Tambah ke favorit',
            ),
          ],
        ),
      ),
    );
  }
}
