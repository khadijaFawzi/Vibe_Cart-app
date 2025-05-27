class FavoriteItem {
  final String type;            // 'product' أو 'offer'
  final int id;                 // هو نفسه favoritable_id
  final int? productId;         // في حال كانت المفضلة عرضاً، يعبّر عن المنتج المرتبط
  final String? productName;
  final int supermarketId;
  final String supermarketName;
  final DateTime favoritedAt;

  // حقول عرض خاصة
  final double? discountPercentage;
  final String? description;
  final String? offerImage;

  FavoriteItem({
    required this.type,
    required this.id,
    this.productId,
    this.productName,
    required this.supermarketId,
    required this.supermarketName,
    required this.favoritedAt,
    this.discountPercentage,
    this.description,
    this.offerImage,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      type: json['type'] as String,
      id: json['id'] as int,
      productId: json['type'] == 'offer'
          ? json['product_id'] as int
          : json['id'] as int,
      productName: json['type'] == 'offer'
          ? (json['product_name'] as String? ?? '')
          : (json['name'] as String? ?? ''),
      supermarketId: json['supermarket_id'] as int,
      supermarketName: (json['supermarket_name'] as String?) ?? '',
      favoritedAt: DateTime.parse(json['favorited_at'] as String),

      // حقول العروض (قد تكون null للمنتجات)
      discountPercentage: json['discount_percentage'] != null
          ? (json['discount_percentage'] as num).toDouble()
          : null,
      description: json['description'] as String?,
      offerImage: json['offer_image'] as String?,
    );
  }
}
