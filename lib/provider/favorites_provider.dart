import 'package:flutter/material.dart';
import 'package:vibe_cart/api/api_service.dart';
import '../models/favorite_item.dart';


class FavoritesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<FavoriteItem> _favorites = [];
  bool _isLoading = false;
  String _error = '';

  List<FavoriteItem> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String get error => _error;

  /// جلب قائمة المفضلات
  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _favorites = await _api.getFavorites();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة منتج إلى المفضلة ثم تحديث القائمة
  Future<void> addFavorite(int productId) async {
    _error = '';
    try {
      final success = await _api.addFavorite(productId);
      if (success) {
        await loadFavorites();
      } else {
        _error = 'فشل في إضافة المفضلة';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// إزالة منتج من المفضلة ثم تحديث القائمة
  Future<void> removeFavorite(int productId) async {
    _error = '';
    try {
      final success = await _api.removeFavorite(productId);
      if (success) {
        await loadFavorites();
      } else {
        _error = 'فشل في إزالة المفضلة';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// تبديل حالة المفضلة (إضافة/إزالة)
  Future<void> toggleFavorite(int productId) async {
    final exists = _favorites.any((f) => f.productId == productId);
    if (exists) {
      await removeFavorite(productId);
    } else {
      await addFavorite(productId);
    }
  }

Future<void> clearFavorites() async {
  // مثال: DELETE لكل عنصر
  for (var fav in List<FavoriteItem>.from(_favorites)) {
    await removeFavorite(fav.productId);
  }
  // أو إذا كان لديك endpoint bulk:
  // await _api.clearAllFavorites();

  // ثم تفريغ القائمة محليًّا
  _favorites.clear();
  notifyListeners();
}

}
