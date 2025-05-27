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

  /// جلب قائمة المفضّلات مع إمكانية تمرير فلاتر
  Future<void> loadFavorites({
    String? type,
    int? supermarketId,
    String? fromDate,
    String? toDate,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _favorites = await _api.getFavorites(
        type: type,
        supermarketId: supermarketId,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة عنصر إلى المفضّلات ثم تحديث القائمة
  Future<void> addFavorite({
    required String type,           // 'product' أو 'offer'
    required int favoritableId,
  }) async {
    _error = '';
    notifyListeners();

    try {
      final success = await _api.addFavorite(
        type: type,
        favoritableId: favoritableId,
      );
      if (success) {
        await loadFavorites();
      } else {
        _error = 'فشل في إضافة المفضلة';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// إزالة عنصر من المفضّلات ثم تحديث القائمة
  Future<void> removeFavorite({
    required String type,           // 'product' أو 'offer'
    required int favoritableId,
  }) async {
    _error = '';
    notifyListeners();

    try {
      final success = await _api.removeFavorite(
        type: type,
        favoritableId: favoritableId,
      );
      if (success) {
        await loadFavorites();
      } else {
        _error = 'فشل في إزالة المفضلة';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// تبديل حالة المفضلة بناءً على الـ id العام
  Future<void> toggleFavorite(FavoriteItem item) async {
    if (_favorites.any((f) => f.type == item.type && f.id == item.id)) {
      await removeFavorite(
        type: item.type,
        favoritableId: item.id,
      );
    } else {
      await addFavorite(
        type: item.type,
        favoritableId: item.id,
      );
    }
  }

  /// مسح جميع المفضّلات (مثال: حذف كل عنصر على حدة)
  Future<void> clearFavorites() async {
    for (var fav in List<FavoriteItem>.from(_favorites)) {
      await removeFavorite(
        type: fav.type,
        favoritableId: fav.id,
      );
    }
    _favorites.clear();
    notifyListeners();
  }
}
