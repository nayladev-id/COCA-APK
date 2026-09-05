// lib/screens/manage_stock_screen.dart

import 'package:flutter/material.dart';
import '../models/coffee_model.dart';
import '../models/stock_model.dart'; 
import '../services/coffee_api_service.dart';

class ManageStockScreen extends StatefulWidget {
  const ManageStockScreen({super.key});

  @override
  State<ManageStockScreen> createState() => _ManageStockScreenState();
}

class _ManageStockScreenState extends State<ManageStockScreen> {
  final _coffeeService = CoffeeApiService();
  bool _isLoading = true;
  List<CoffeeModel> _allCoffees = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final hot = await _coffeeService.fetchHotCoffee();
      final iced = await _coffeeService.fetchIcedCoffee();
      final lokal = await _coffeeService.fetchKopiNusantara();
      
      if (mounted) {
        setState(() {
          _allCoffees = [...hot, ...iced, ...lokal];
          final seen = <String>{};
          _allCoffees.retainWhere((c) => seen.add(c.title));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Kelola Stok Menu'),
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ValueListenableBuilder<Map<String, int>>(
            valueListenable: stockNotifier,
            builder: (context, stockMap, child) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allCoffees.length,
                itemBuilder: (context, index) {
                  final coffee = _allCoffees[index];
                  // Baca stok, jika belum ada di map, anggap stoknya 20
                  final currentStock = stockMap[coffee.title] ?? 20;
                  final isHabis = currentStock <= 0;

                  return Card(
                    color: isHabis ? Colors.red.shade50 : theme.colorScheme.surface,
                    elevation: isHabis ? 0 : 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isHabis ? BorderSide(color: Colors.red.shade200) : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: isHabis ? 0.4 : 1.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                coffee.image,
                                width: 50, height: 50, fit: BoxFit.cover,
                                errorBuilder: (_,__,___) => Container(
                                  width: 50, height: 50, color: Colors.grey.shade300,
                                  child: const Icon(Icons.coffee),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coffee.title, 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    decoration: isHabis ? TextDecoration.lineThrough : null,
                                    color: isHabis ? Colors.red.shade900 : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isHabis ? 'Stok Kosong' : 'Sisa Stok: $currentStock Cup', 
                                  style: TextStyle(
                                    color: isHabis ? Colors.red : Colors.green.shade700, 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  )
                                ),
                              ],
                            ),
                          ),
                          // Pengatur Angka Stok (+ / -)
                          Container(
                            decoration: BoxDecoration(
                              color: isHabis ? Colors.red.shade100 : Colors.brown.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, color: isHabis ? Colors.red : Colors.brown, size: 20),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    if (currentStock > 0) {
                                      final newMap = Map<String, int>.from(stockNotifier.value);
                                      newMap[coffee.title] = currentStock - 1;
                                      stockNotifier.value = newMap;
                                    }
                                  },
                                ),
                                Text('$currentStock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isHabis ? Colors.red : Colors.brown)),
                                IconButton(
                                  icon: Icon(Icons.add, color: isHabis ? Colors.red : Colors.brown, size: 20),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    final newMap = Map<String, int>.from(stockNotifier.value);
                                    newMap[coffee.title] = currentStock + 1;
                                    stockNotifier.value = newMap;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          ),
    );
  }
}