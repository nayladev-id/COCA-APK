// lib/models/stock_model.dart

import 'package:flutter/material.dart';

// Menyimpan daftar nama kopi yang sedang habis (Out of Stock)
final ValueNotifier<Set<String>> outOfStockNotifier = ValueNotifier<Set<String>>({});