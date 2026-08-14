// lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import '../models/coffee_model.dart';
import '../models/terjemahan_model.dart';
import '../models/cart_model.dart'; 
import '../utils/image_overrides.dart';
import '../utils/ingredient_translator.dart';
import 'checkout_screen.dart';

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
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _isFavorit = widget.isFavorit;
  }

  int _getDummyPrice() {
    return widget.isIced ? 28000 : 25000;
  }

  void _prosesPesanan({required bool isBeliLangsung}) {
    final price = _getDummyPrice();

    if (isBeliLangsung) {
      final singleItem = CartItem(
        id: widget.coffee.id, 
        nama: widget.coffee.title,
        image: widget.coffee.image,
        harga: price,
        quantity: _quantity,
        isIced: widget.isIced,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(directItem: [singleItem]),
        ),
      );
    } else {
      final currentCart = List<CartItem>.from(cartNotifier.value);
      int existingIndex = currentCart.indexWhere((item) => 
          item.nama == widget.coffee.title && item.isIced == widget.isIced);
      
      if (existingIndex != -1) {
        currentCart[existingIndex].quantity += _quantity;
      } else {
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
      
      cartNotifier.value = currentCart;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_quantity}x ${widget.coffee.title} ditambahkan ke keranjang!'),
          backgroundColor: Colors.brown,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2), 
        ),
      );
    }
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                style: const TextStyle(shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
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
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _isFavorit ? Colors.red.shade100 : colorScheme.primaryContainer,
                        foregroundColor: _isFavorit ? Colors.red.shade800 : colorScheme.onPrimaryContainer,
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

                  _sectionTitle(context, '📝 Deskripsi Asli'),
                  const SizedBox(height: 8),
                  Text(coffee.description, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 20),

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
                  Text('ID Sample API: ${coffee.id}', style: TextStyle(color: colorScheme.outline, fontSize: 12)),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Text(
                    'Rp $totalHarga', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _prosesPesanan(isBeliLangsung: false),
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('+ Keranjang'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.brown,
                        side: const BorderSide(color: Colors.brown),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    // PERBAIKAN: Membuang .icon dan membuang Icon petir
                    child: FilledButton(
                      onPressed: () => _prosesPesanan(isBeliLangsung: true),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Beli Langsung', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}