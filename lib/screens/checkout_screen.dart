// lib/screens/checkout_screen.dart

import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import 'home_screen.dart';

class CheckoutScreen extends StatefulWidget {
  // PERBAIKAN: Menambahkan opsi pesanan langsung (Jalur VIP)
  final List<CartItem>? directItem; 
  
  const CheckoutScreen({super.key, this.directItem});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _mejaController = TextEditingController();
  String _selectedPayment = 'QRIS';
  
  late List<CartItem> _itemsToCheckout;

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Jika ada directItem (Beli Langsung), pakai itu. Jika tidak, pakai Keranjang Global.
    _itemsToCheckout = widget.directItem ?? cartNotifier.value;
  }

  void _prosesPembayaran(int totalBelanja) {
    if (_mejaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor meja tidak boleh kosong!'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _selectedPayment == 'QRIS' ? 'Scan QRIS' 
          : _selectedPayment == 'Transfer Bank' ? 'Transfer ke Rekening' 
          : 'Pembayaran Tunai',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedPayment == 'QRIS') ...[
              const Icon(Icons.qr_code_2, size: 150),
              const SizedBox(height: 8),
              const Text('Gopay / OVO / Dana / ShopeePay', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ] else if (_selectedPayment == 'Transfer Bank') ...[
              const Icon(Icons.account_balance, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text('BCA: 1234567890\nA.N. Vintage Roastery', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Silakan transfer sesuai nominal:\nRp $totalBelanja', textAlign: TextAlign.center),
            ] else ...[
              const Icon(Icons.payments, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text('Pesanan Anda akan segera diantar.\nMohon siapkan uang pas sebesar:', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Rp $totalBelanja', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _selesaikanPesanan(totalBelanja); 
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.brown),
            child: const Text('Saya Sudah Bayar'),
          ),
        ],
      ),
    );
  }

  void _selesaikanPesanan(int totalBelanja) {
    final newOrder = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      meja: _mejaController.text.trim(),
      items: List.from(_itemsToCheckout), // Menggunakan data yang di-checkout, bukan selalu global cart
      totalHarga: totalBelanja,
      paymentMethod: _selectedPayment,
      createdAt: DateTime.now(),
    );
    
    globalOrderNotifier.value = [newOrder, ...globalOrderNotifier.value]; 

    // PERBAIKAN: Hanya kosongkan keranjang pelanggan JIKA yang di-checkout adalah Keranjang Global
    if (widget.directItem == null) {
      cartNotifier.value = [];
    }
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Pesanan diterima! Barista kami sedang meracik kopimu.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalHarga = _itemsToCheckout.fold(0, (sum, item) => sum + item.subtotal);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📍 Lokasi Anda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _mejaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Contoh: 04',
                labelText: 'Nomor Meja',
                prefixIcon: const Icon(Icons.table_restaurant),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),

            const Text('📝 Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: _itemsToCheckout.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.quantity}x ${item.nama}', style: const TextStyle(fontSize: 14)),
                        Text('Rp ${item.subtotal}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            const Text('💳 Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Radio<String>(
                      value: 'QRIS',
                      groupValue: _selectedPayment,
                      onChanged: (val) => setState(() => _selectedPayment = val.toString()),
                    ),
                    title: const Text('QRIS (Gopay, OVO, Dana)'),
                    trailing: const Icon(Icons.qr_code, color: Colors.pink),
                    onTap: () => setState(() => _selectedPayment = 'QRIS'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Radio<String>(
                      value: 'Transfer Bank',
                      groupValue: _selectedPayment,
                      onChanged: (val) => setState(() => _selectedPayment = val.toString()),
                    ),
                    title: const Text('Transfer Bank'),
                    trailing: const Icon(Icons.account_balance, color: Colors.blue),
                    onTap: () => setState(() => _selectedPayment = 'Transfer Bank'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Radio<String>(
                      value: 'Cash',
                      groupValue: _selectedPayment,
                      onChanged: (val) => setState(() => _selectedPayment = val.toString()),
                    ),
                    title: const Text('Bayar Tunai di Meja'),
                    trailing: const Icon(Icons.payments, color: Colors.green),
                    onTap: () => setState(() => _selectedPayment = 'Cash'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: FilledButton(
            onPressed: () => _prosesPembayaran(totalHarga),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.brown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text('Bayar Rp $totalHarga', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}