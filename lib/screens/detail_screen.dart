// lib/screens/detail_screen.dart
// Menampilkan detail lengkap 1 kopi + aksi tambah/hapus favorit

import 'package:flutter/material.dart';
import '../models/coffee_model.dart';
import '../models/terjemahan_model.dart';
import '../utils/image_overrides.dart';
import '../utils/ingredient_translator.dart';

class DetailScreen extends StatefulWidget {
  final CoffeeModel coffee;
  final TerjemahanModel? terjemahan;
  final bool isFavorit;
  final bool isIced;
  final VoidCallback onFavoritToggle;

  const DetailScreen({
    super.key,
    required this.coffee,
    this.terjemahan,
    required this.isFavorit,
    required this.isIced,
    required this.onFavoritToggle,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool _isFavorit;

  @override
  void initState() {
    super.initState();
    _isFavorit = widget.isFavorit;
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coffee = widget.coffee;
    final terjemahan = widget.terjemahan;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                coffee.title,
                style: const TextStyle(
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
              ),
              background: ImageOverrides.buildImage(
                title: coffee.title,
                isIced: widget.isIced,
                networkUrl: coffee.image,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.coffee, size: 80),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Favorit
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _isFavorit
                            ? Colors.red.shade100 : colorScheme.primaryContainer,
                        foregroundColor: _isFavorit
                            ? Colors.red.shade800 : colorScheme.onPrimaryContainer,
                      ),
                      onPressed: () {
                        widget.onFavoritToggle();
                        setState(() => _isFavorit = !_isFavorit);
                      },
                      icon: Icon(_isFavorit ? Icons.favorite : Icons.favorite_border),
                      label: Text(_isFavorit ? 'Hapus dari Favorit' : 'Tambah ke Favorit'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Deskripsi Indonesia
                  if (terjemahan != null) ...[
                    _sectionTitle(context, '🇮🇩 Deskripsi (Indonesia)'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(terjemahan.deskripsiId),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Deskripsi Asli
                  _sectionTitle(context, '📝 Deskripsi Asli'),
                  const SizedBox(height: 8),
                  Text(coffee.description,
                      style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 20),

                  // Bahan-bahan
                  _sectionTitle(context, '🧪 Bahan-bahan'),
                  const SizedBox(height: 8),
                  ...coffee.ingredients.map((ing) {
                    final translated = IngredientTranslator.translate(ing);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        Icon(Icons.circle, size: 8, color: colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(child: Text(translated)),
                      ]),
                    );
                  }),
                  const SizedBox(height: 16),
                  Text('ID Sample API: ${coffee.id}',
                      style: TextStyle(color: colorScheme.outline, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
