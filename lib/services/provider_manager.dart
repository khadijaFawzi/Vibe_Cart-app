import 'package:flutter/material.dart';
import 'package:vibe_cart/models/category_model.dart';
import 'package:vibe_cart/models/center_model.dart';
import 'package:vibe_cart/models/product_supermarket_model.dart';
import 'package:vibe_cart/services/api_service_old.dart';
import 'package:vibe_cart/services/cart_service.dart';
import 'package:vibe_cart/services/favorites_service.dart';


class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  List<Product> _offers = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get products => _products;
  List<Product> get offers => _offers;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _products = await _apiService.getProducts();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOffers() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _offers = await _apiService.getOffers();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> getCategoryProducts(int categoryId) async {
    try {
      return await _apiService.getCategoryProducts(categoryId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<Product>> getCenterProducts(int centerId) async {
    try {
      return await _apiService.getCenterProducts(centerId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<Product>> getCenterCategoryProducts(int centerId, int categoryId) async {
    try {
      return await _apiService.getCenterCategoryProducts(centerId, categoryId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<Product>> getProductPriceComparison(int productId) async {
    try {
      return await _apiService.getProductPriceComparison(productId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
}

class CenterProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ShoppingCenter> _centers = [];
  bool _isLoading = false;
  String _error = '';

  List<ShoppingCenter> get centers => _centers;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadCenters() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _centers = await _apiService.getCenters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> get cartItems => _cartService.cartItems;
  double get totalPrice => _cartService.totalPrice;
  int get itemCount => _cartService.itemCount;

  void addToCart(Product product, {int quantity = 1}) {
    _cartService.addToCart(product, quantity: quantity);
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cartService.removeFromCart(productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int newQuantity) {
    _cartService.updateQuantity(productId, newQuantity);
    notifyListeners();
  }

  void clearCart() {
    _cartService.clearCart();
    notifyListeners();
  }

  bool isInCart(int productId) {
    return _cartService.isInCart(productId);
  }
}

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();

  List<Product> get favorites => _favoritesService.favorites;
  int get favoriteCount => _favoritesService.favoriteCount;

  void addToFavorites(Product product) {
    _favoritesService.addToFavorites(product);
    notifyListeners();
  }

  void removeFromFavorites(int productId) {
    _favoritesService.removeFromFavorites(productId);
    notifyListeners();
  }

  bool isInFavorites(int productId) {
    return _favoritesService.isInFavorites(productId);
  }

  void clearFavorites() {
    _favoritesService.clearFavorites();
    notifyListeners();
  }
}
