// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _tambahKuantitas(CartItem item) {
    item.quantity++;
    cartNotifier.value = List.from(cartNotifier.value);
  }

  void _kurangiKuantitas(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      cartNotifier.value.remove(item);
    }
    cartNotifier.value = List.from(cartNotifier.value);
  }

  void _tambahCatatan(BuildContext context, CartItem item) {
    final TextEditingController catatanController = TextEditingController(text: item.catatan);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Catatan Pesanan'),
        content: TextField(
          controller: catatanController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Contoh: Less sugar, extra es...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              item.catatan = catatanController.text.trim();
              cartNotifier.value = List.from(cartNotifier.value);
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Keranjang Saya'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartNotifier,
        builder: (context, cartItems, child) {
          if (cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Keranjangmu masih kosong nih.', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Yuk, eksplorasi menu kafe kami!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80, height: 80, color: Colors.grey[300],
                            child: const Icon(Icons.coffee),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nama,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              item.isIced ? '❄️ Iced' : '🔥 Hot',
                              style: TextStyle(color: item.isIced ? Colors.blue : Colors.red, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            // PERBAIKAN: Menampilkan Subtotal (Harga Asli x Jumlah)
                            Text(
                              'Rp ${item.subtotal}', 
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            
                            if (item.catatan.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit_note, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(item.catatan, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _kurangiKuantitas(item),
                                visualDensity: VisualDensity.compact,
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _tambahKuantitas(item),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => _tambahCatatan(context, item),
                            icon: const Icon(Icons.note_add, size: 16),
                            label: const Text('Catatan', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartNotifier,
        builder: (context, cartItems, child) {
          if (cartItems.isEmpty) return const SizedBox.shrink();

          int totalHarga = cartItems.fold(0, (sum, item) => sum + item.subtotal);

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('Rp $totalHarga', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
                  icon: const Icon(Icons.payment),
                  label: const Text('Checkout'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.brown,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}