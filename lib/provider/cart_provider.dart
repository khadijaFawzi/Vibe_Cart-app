import 'package:flutter/material.dart';
import 'package:vibe_cart/api/api_service.dart';
import 'package:vibe_cart/models/cart_group.dart';

class CartProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<CartGroup> groups = [];

  /// جلب محتويات السلة وتحديث الواجهة
  Future<void> loadCart() async {
    groups = await _api.getCart();
    notifyListeners();
  }

  /// إضافة منتج إلى السلة
  Future<void> add(int productId, int supermarketId, int quantity) async {
    await _api.addToCart(productId, supermarketId, quantity);
    await loadCart();
  }

  /// تحديث كمية منتج في السلة
  Future<void> update(int cartItemId, int quantity) async {
    await _api.updateCart(cartItemId, quantity);
    await loadCart();
  }

  /// إزالة عنصر من السلة
  Future<void> remove(int cartItemId) async {
    await _api.removeFromCart(cartItemId);
    await loadCart();
  }

  /// تفريغ كامل محتويات السلة
  Future<void> clearCart(int supermarketId) async {
  await _api.clearCart(supermarketId);
  await loadCart();
}

   /// التحقق إن كان المنتج موجودًا في السلة
  bool isInCart(int productId) {
    return groups
        .any((group) => group.items.any((item) => item.productId == productId));
  }
}
