// lib/services/supermarket_provider.dart

import 'package:flutter/material.dart';
import 'package:vibe_cart/api/api_service.dart';

import 'package:vibe_cart/models/supermarket.dart';

class SuperMarketProvider with ChangeNotifier {
  // استدعاء ApiService بدون معامل baseUrl
  final ApiService _api = ApiService();

  List<SuperMarket> supermarkets = [];
  bool isLoading = false;
  String error = '';

  Future<void> loadSupermarkets() async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      supermarkets = await _api.getSupermarkets();
      print('>>> Supermarkets fetched: ${supermarkets.length}');
      if (supermarkets.isEmpty) {
        error = 'لم يتم العثور على سوبرماركتات';
      }
    } catch (e) {
      error = 'فشل في جلب السوبرماركتات: $e';
    }

    isLoading = false;
    notifyListeners();
  }
}
