import 'package:flutter/material.dart';
import '../models/food_basket.dart';
import '../api/api_service.dart';

class FoodBasketProvider with ChangeNotifier {
  List<FoodBasket> _foodBaskets = [];
  bool isLoading = false;
  String error = '';

  List<FoodBasket> get foodBaskets => _foodBaskets;
Future<void> fetchFoodBaskets(int supermarketId) async {
  isLoading = true;
  error = '';
  notifyListeners();

  try {
    final response = await ApiService().dioInstance.get('/supermarkets/$supermarketId/food-baskets');
    print('Food Baskets API response: ${response.data}');

    if (response.statusCode == 200 && response.data['status'] == true) {
      final list = response.data['data'] as List;
      _foodBaskets = list.map((j) => FoodBasket.fromJson(j)).toList();
    } else {
      _foodBaskets = [];
    }
  } catch (e) {
    error = 'خطأ أثناء جلب السلات الغذائية';
    print('Error fetching food baskets: $e');
    _foodBaskets = [];
  }
  isLoading = false;
  notifyListeners();
}
Future<void> fetchAllFoodBaskets() async {
  isLoading = true;
  error = '';
  notifyListeners();

  try {
    final list = await ApiService().getAllFoodBaskets();
    _foodBaskets = list;
  } catch (e) {
    error = 'حدث خطأ أثناء جلب السلات الغذائية';
    print('Error: $e');
  }
  isLoading = false;
  notifyListeners();
}

}