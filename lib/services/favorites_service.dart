


import 'package:vibe_cart/models/product_supermarket_model.dart';

class FavoritesService {
  final List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  int get favoriteCount => _favorites.length;

  void addToFavorites(Product product) {
    if (!isInFavorites(product.id)) {
      _favorites.add(product);
    }
  }

  void removeFromFavorites(int productId) {
    _favorites.removeWhere((product) => product.id == productId);
  }

  bool isInFavorites(int productId) {
    return _favorites.any((product) => product.id == productId);
  }

  void clearFavorites() {
    _favorites.clear();
  }
}
