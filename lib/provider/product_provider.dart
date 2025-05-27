// lib/provider/product_provider.dart

import 'package:flutter/material.dart';
import 'package:vibe_cart/api/api_service.dart';
import 'package:vibe_cart/models/category_model.dart';
import 'package:vibe_cart/models/price_comparison.dart';
import 'package:vibe_cart/models/product.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> products = [];
  bool isLoading = false;
  String error = '';
// تخزين مؤقت لعدد التقييمات لكل منتج
Map<int, int> _reviewsCount = {};

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


Future<List<Product>> getProductsBySupermarketAndCategory(int supermarketId, int categoryId) async {
  try {
    if (products.isEmpty) {
      products = await _api.getAllProducts();
    }
    // اطبع جميع المنتجات للتاكد
    print("Total products loaded: ${products.length}");
    for (var p in products) {
      print("product: ${p.productName} - supermarket: ${p.supermarketId} - category: ${p.categoryId}");
    }

    final filtered = products.where((p) => p.supermarketId == supermarketId && p.categoryId == categoryId).toList();
    print("Filtered products: ${filtered.length}");

    filtered.sort((a, b) => a.productName.compareTo(b.productName));
    return filtered;
  } catch (e) {
    error = 'فشل في جلب المنتجات: $e';
    notifyListeners();
    return [];
  }
}


/// جلب المنتجات مباشرة من السيرفر حسب السوبرماركت والفئة
Future<List<Product>> fetchProductsBySupermarketAndCategory(int supermarketId, int categoryId) async {
  try {
    final list = await _api.getProductsBySupermarketAndCategory(supermarketId, categoryId);
    return list;
  } catch (e) {
    error = 'فشل في جلب المنتجات: $e';
    notifyListeners();
    return [];
  }
}
// جلب فئات سوبرماركت محدد
Future<List<Category>> fetchCategoriesBySupermarket(int supermarketId) async {
  try {
    return await _api.getCategoriesBySupermarket(supermarketId);
  } catch (e) {
    error = 'فشل في جلب فئات السوبرماركت: $e';
    notifyListeners();
    return [];
  }
}






  /// جلب المنتجات المشابهة حسب المنتج الحالي
  Future<List<Product>> fetchSimilarProducts(int productId) async {
    try {
      return await _api.getSimilarProducts(productId);
    } catch (e) {
      error = 'فشل في جلب المنتجات المشابهة: $e';
      notifyListeners();
      return [];
    }
  }


/// جلب عدد التقييمات لمنتج معيّن
Future<int> fetchReviewsCount(int productId, {bool force = false}) async {
  if (_reviewsCount.containsKey(productId) && !force) {
    return _reviewsCount[productId]!;
  }
  try {
    final count = await _api.fetchReviewsCount(productId);
    _reviewsCount[productId] = count;
    notifyListeners();
    return count;
  } catch (e) {
    error = 'فشل في جلب عدد التقييمات: $e';
    notifyListeners();
    return 0;
  }
}

Future<void> rateProduct(int productId, int rating, String token) async {
  await _api.rateProduct(productId, rating, token: token);
  await fetchReviewsCount(productId, force: true);
}

int getReviewsCount(int productId) {
  return _reviewsCount[productId] ?? 0;
}


}
