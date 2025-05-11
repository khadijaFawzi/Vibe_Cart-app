// lib/services/cart_service.dart

 

import 'package:vibe_cart/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.discountedPrice * quantity;
}

class CartService {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += item.totalPrice;
    }
    return total;
  }

  int get itemCount => _cartItems.length;

  void addToCart(Product product, {int quantity = 1}) {
    // البحث عن المنتج في السلة
    final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex != -1) {
      // المنتج موجود بالفعل، زيادة الكمية
      _cartItems[existingItemIndex].quantity += quantity;
    } else {
      // إضافة منتج جديد إلى السلة
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final itemIndex = _cartItems.indexWhere((item) => item.product.id == productId);
    if (itemIndex != -1) {
      _cartItems[itemIndex].quantity = newQuantity;
    }
  }

  void clearCart() {
    _cartItems.clear();
  }

  bool isInCart(int productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }
}

 