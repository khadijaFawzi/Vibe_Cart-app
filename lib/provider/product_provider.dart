// lib/provider/product_provider.dart

import 'package:flutter/material.dart';
import 'package:vibe_cart/api/api_service.dart';
import 'package:vibe_cart/models/price_comparison.dart';
import 'package:vibe_cart/models/product.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> products = [];
  bool isLoading = false;
  String error = '';

  /// قائمة المنتجات بدون تكرار حسب barcode أو الاسم
  List<Product> get uniqueProducts {
    final map = <String, Product>{};
    for (var p in products) {
      final key = p.barcode.isNotEmpty ? p.barcode : p.productName;
      if (!map.containsKey(key)) {
        map[key] = p;
      }
    }
    return map.values.toList();
  }

  /// جلب جميع المنتجات
  Future<void> loadProducts() async {
    isLoading = true;
    error = '';
    notifyListeners();
    try {
      products = await _api.getAllProducts();
    } catch (e) {
      error = 'فشل في جلب المنتجات: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  /// جلب منتجات سوبرماركت محدد
  Future<List<Product>> getProductsBySupermarket(int supermarketId) async {
    try {
      return await _api.getProductsBySupermarket(supermarketId);
    } catch (e) {
      error = 'فشل في جلب منتجات السوبرماركت: $e';
      notifyListeners();
      return [];
    }
  }

  /// مقارنة أسعار المنتج بالباركود
  Future<PriceComparison> getComparisonByBarcode(String barcode) async {
    try {
      return await _api.compareByBarcode(barcode);
    } catch (e) {
      error = 'فشل في جلب مقارنة الأسعار: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// جلب منتج واحد بالباركود
  Future<Product> getProductByBarcode(String barcode) async {
    try {
      return await _api.getProductByBarcode(barcode);
    } catch (e) {
      error = 'فشل في جلب المنتج بالباركود: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Product>> loadProductsByCategory(int categoryId) async {
  isLoading = true;
  error = '';
  notifyListeners();

  try {
    products = await _api.getProductsByCategory(categoryId);
    if (products.isEmpty) {
      error = 'لا توجد منتجات في هذه الفئة';
    }
  } catch (e) {
    error = 'فشل في جلب المنتجات: $e';
  }

  isLoading = false;
  notifyListeners();
  return products;
}
Future<List<Product>> fetchProductsByCategory(int categoryId) async {
  try {
    final list = await _api.getProductsByCategory(categoryId);
    return list;
  } catch (e) {
    error = 'فشل في جلب المنتجات: $e';
    notifyListeners();
    return [];
  }
}

}
