// lib/models/cart_model.dart

import 'package:flutter/material.dart';

class CartItem {
  final int id;
  final String nama;
  final String image;
  final int harga; 
  int quantity;
  String catatan;
  final bool isIced;

  CartItem({
    required this.id,
    required this.nama,
    required this.image,
    required this.harga,
    this.quantity = 1,
    this.catatan = '',
    this.isIced = false,
  });

  // Fungsi pembantu untuk menghitung subtotal per item
  int get subtotal => harga * quantity;
}

// Jembatan Komunikasi Global untuk Keranjang Belanja
final ValueNotifier<List<CartItem>> cartNotifier = ValueNotifier<List<CartItem>>([]);