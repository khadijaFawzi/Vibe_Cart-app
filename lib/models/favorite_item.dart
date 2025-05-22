class FavoriteItem {
  final int productId;
  final String productName;
  final int supermarketId;
  final String supermarketName;
  final DateTime favoritedAt;

  FavoriteItem({
    required this.productId,
    required this.productName,
    required this.supermarketId,
    required this.supermarketName,
    required this.favoritedAt,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      productId: json['product_id'] as int,
      productName: (json['product_name'] as String?) ?? '',
      supermarketId: json['supermarket_id'] as int,
      supermarketName: (json['supermarket_name'] as String?) ?? '',
      favoritedAt: json['favorited_at'] != null
          ? DateTime.parse(json['favorited_at'] as String)
          : DateTime.now(),
    );
  }
}
