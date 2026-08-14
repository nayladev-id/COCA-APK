// lib/models/order_model.dart

import 'package:flutter/material.dart';
import 'cart_model.dart';

class OrderModel {
  final String id;
  final String meja;
  final List<CartItem> items;
  final int totalHarga;
  final String paymentMethod;
  String status; // 'Menunggu', 'Diproses', 'Selesai'
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.meja,
    required this.items,
    required this.totalHarga,
    required this.paymentMethod,
    this.status = 'Menunggu',
    required this.createdAt,
  });
}

// JEMBATAN KOMUNIKASI: Database simulasi untuk pesanan masuk
final ValueNotifier<List<OrderModel>> globalOrderNotifier = ValueNotifier<List<OrderModel>>([]);