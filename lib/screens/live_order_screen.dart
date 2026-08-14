// lib/screens/live_order_screen.dart

import 'package:flutter/material.dart';
import '../models/order_model.dart';

class LiveOrderScreen extends StatelessWidget {
  const LiveOrderScreen({super.key});

  void _updateStatus(OrderModel order, String statusBaru) {
    order.status = statusBaru;
    // Pancing notifer agar layarnya me-refresh data terbaru
    globalOrderNotifier.value = List.from(globalOrderNotifier.value);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu': return Colors.red;
      case 'Diproses': return Colors.orange;
      case 'Selesai': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👨‍🍳 Live Orders (Dapur)'),
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<List<OrderModel>>(
        valueListenable: globalOrderNotifier,
        builder: (context, orders, child) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada pesanan masuk.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              // Format waktu sederhana HH:MM
              final jamMasuk = '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card (Meja & Waktu & Status)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.brown.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Meja ${order.meja}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 18),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(jamMasuk, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                      const Divider(height: 24),
                      
                      // Daftar Menu
                      ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item.nama} (${item.isIced ? 'Iced' : 'Hot'})', style: const TextStyle(fontSize: 15)),
                                  if (item.catatan.isNotEmpty)
                                    Text('Catatan: ${item.catatan}', style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                      const Divider(height: 24),

                      // Footer Card (Total Bayar & Tombol Aksi)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text('Rp ${order.totalHarga}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                            ],
                          ),
                          // Dropdown Ubah Status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: _getStatusColor(order.status)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: DropdownButton<String>(
                              value: order.status,
                              underline: const SizedBox(), // Hilangkan garis bawah
                              icon: Icon(Icons.arrow_drop_down, color: _getStatusColor(order.status)),
                              style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold),
                              items: ['Menunggu', 'Diproses', 'Selesai'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) _updateStatus(order, newValue);
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}