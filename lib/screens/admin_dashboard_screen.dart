// lib/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../models/order_model.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('👑 Dasbor Pemilik (Owner)'),
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<List<OrderModel>>(
        valueListenable: globalOrderNotifier,
        builder: (context, orders, child) {
          // Menghitung statistik penjualan
          final totalPesanan = orders.length;
          final totalPendapatan = orders.fold<int>(0, (sum, item) => sum + item.totalHarga);
          final pesananSelesai = orders.where((o) => o.status == 'Selesai').length;
          final pesananDiproses = orders.where((o) => o.status == 'Diproses' || o.status == 'Menunggu').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Penjualan Hari Ini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Baris Kartu Metrik
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: 'Total Omzet',
                        value: 'Rp $totalPendapatan',
                        icon: Icons.monetization_on,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: 'Total Pesanan',
                        value: '$totalPesanan Order',
                        icon: Icons.receipt_long,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: 'Sedang Berjalan',
                        value: '$pesananDiproses',
                        icon: Icons.hourglass_top,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: 'Order Selesai',
                        value: '$pesananSelesai',
                        icon: Icons.check_circle,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Aktivitas Transaksi Terakhir',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (orders.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Belum ada data transaksi yang tercatat.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length > 5 ? 5 : orders.length, // Tampilkan 5 transaksi terakhir
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      
                      // PERBAIKAN: Menggabungkan nama kopi yang dipesan beserta jumlahnya
                      final rincianPesanan = order.items.map((item) => '${item.quantity}x ${item.nama}').join(', ');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.brown.shade100,
                            child: Text(
                              order.meja,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                            ),
                          ),
                          title: Text('Meja ${order.meja} - Rp ${order.totalHarga}'),
                          // PERBAIKAN: Menampilkan rincian nama kopi alih-alih jumlah macamnya
                          subtitle: Text(
                            '$rincianPesanan • ${order.paymentMethod}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(height: 1.4),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: order.status == 'Selesai'
                                  ? Colors.green.shade100
                                  : order.status == 'Diproses'
                                      ? Colors.orange.shade100
                                      : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: order.status == 'Selesai'
                                    ? Colors.green.shade800
                                    : order.status == 'Diproses'
                                        ? Colors.orange.shade800
                                        : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}