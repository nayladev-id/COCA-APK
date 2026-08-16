// lib/screens/manage_stock_screen.dart

import 'package:flutter/material.dart';
import '../models/coffee_model.dart';
import '../models/stock_model.dart'; // IMPORT MODEL STOK
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
          // Menghapus duplikat nama kopi jika ada menu yang sama
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Kelola Stok Menu'),
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ValueListenableBuilder<Set<String>>(
            valueListenable: outOfStockNotifier,
            builder: (context, outOfStockSet, child) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allCoffees.length,
                itemBuilder: (context, index) {
                  final coffee = _allCoffees[index];
                  // Cek apakah kopi ini ada di daftar "Habis"
                  final isHabis = outOfStockSet.contains(coffee.title);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: ClipRRect(
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
                      title: Text(coffee.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        isHabis ? 'Stok Habis' : 'Tersedia', 
                        style: TextStyle(color: isHabis ? Colors.red : Colors.green, fontWeight: FontWeight.bold)
                      ),
                      trailing: Switch(
                        value: !isHabis, // Sakelar hidup jika TIDAK habis
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        onChanged: (isAvailable) {
                          final newSet = Set<String>.from(outOfStockNotifier.value);
                          if (isAvailable) {
                            newSet.remove(coffee.title); // Hidupkan menu
                          } else {
                            newSet.add(coffee.title); // Matikan menu
                          }
                          outOfStockNotifier.value = newSet;
                        },
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