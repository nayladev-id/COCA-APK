// lib/models/stock_model.dart

import 'package:flutter/material.dart';

// Menyimpan jumlah angka stok untuk masing-masing kopi.
// Jika sebuah kopi belum pernah diatur stoknya, kita asumsikan stok bawaannya adalah 20 cup.
final ValueNotifier<Map<String, int>> stockNotifier = ValueNotifier<Map<String, int>>({});