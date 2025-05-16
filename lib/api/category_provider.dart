import 'package:flutter/material.dart';
import 'package:vibe_cart/models/category_model.dart';

import 'api_service.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Category> categories = [];
  bool isLoading = false;
  String error = '';

  Future<void> loadCategories() async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      categories = await _api.getCategories();
      if (categories.isEmpty) {
        error = 'لا توجد فئات متاحة';
      }
    } catch (e) {
      error = 'فشل في جلب الفئات: $e';
    }

    isLoading = false;
    notifyListeners();
  }
}
