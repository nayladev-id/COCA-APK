// lib/screens/detail_screen.dart
// Menampilkan detail lengkap 1 kopi + aksi tambah favorit & Keranjang

import 'package:flutter/material.dart';
import '../models/coffee_model.dart';
import '../models/terjemahan_model.dart';
import '../models/cart_model.dart'; // IMPORT MODEL KERANJANG
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
  int _quantity = 1; // Variabel jumlah pesanan

  @override
  void initState() {
    super.initState();
    _isFavorit = widget.isFavorit;
  }

  // Logika Harga Simulasi
  int _getDummyPrice() {
    return widget.isIced ? 28000 : 25000;
  }

  // Fungsi Memasukkan Kopi ke Keranjang Global
  void _addToCart() {
    final price = _getDummyPrice();
    final currentCart = List<CartItem>.from(cartNotifier.value);
    
    // Cek apakah kopi ini (dengan suhu yang sama) sudah ada di keranjang
    int existingIndex = currentCart.indexWhere((item) => 
        item.nama == widget.coffee.title && item.isIced == widget.isIced);
    
    if (existingIndex != -1) {
      // Jika sudah ada, cukup tambahkan kuantitasnya
      currentCart[existingIndex].quantity += _quantity;
    } else {
      // Jika belum ada, buat pesanan baru
      currentCart.add(
        CartItem(
          id: widget.coffee.id, 
          nama: widget.coffee.title,
          image: widget.coffee.image,
          harga: price,
          quantity: _quantity,
          isIced: widget.isIced,
        )
      );
    }
    
    // Beri tahu sistem bahwa keranjang telah berubah
    cartNotifier.value = currentCart;
    
    // Munculkan notifikasi sukses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_quantity}x ${widget.coffee.title} ditambahkan ke keranjang!'),
        backgroundColor: Colors.brown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
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
    final totalHarga = _getDummyPrice() * _quantity;

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
                  const SizedBox(height: 80), // Spacer agar tidak tertutup tombol bawah
                ],
              ),
            ),
          ),
        ],
      ),
      
      // BOTTOM BAR: Pengatur Jumlah & Tombol Keranjang
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Pengatur Jumlah (+/-)
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                    ),
                    Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Tombol Tambah ke Keranjang
              Expanded(
                child: FilledButton(
                  onPressed: _addToCart,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Pesan - Rp $totalHarga',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}