// lib/provider/product_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vibe_cart/models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('http://localhost:8000/api/customer/products'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['products'];
        _products = list.map((e) => Product.fromJson(e)).toList();
      } else {
        _error = 'حدث خطأ في التحميل: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'تحقق من اتصالك بالإنترنت';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// إرجاع قائمة المنتجات مع إزالة التكرارات حسب الباركود
  List<Product> get uniqueProducts {
    final Map<String, Product> map = {};
    for (var p in _products) {
      final key = p.barcode.isNotEmpty ? p.barcode : p.id.toString();
      if (!map.containsKey(key)) {
        map[key] = p;
      }
    }
    return map.values.toList();
  }
}

