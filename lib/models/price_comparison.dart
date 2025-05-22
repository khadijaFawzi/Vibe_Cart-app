// lib/models/price_comparison.dart

class PriceOffer {
  final int productId;
  final int supermarketId;
  final String supermarketName;
  final double price;
  final String imageUrl;

  PriceOffer({
    required this.productId,
    required this.supermarketId,
    required this.supermarketName,
    required this.price,
    required this.imageUrl,
  });

  factory PriceOffer.fromJson(Map<String, dynamic> json) {
    double price;
    final priceVal = json['price'];
    if (priceVal is num) {
      price = priceVal.toDouble();
    } else {
      price = double.tryParse(json['price']?.toString() ?? '') ?? 0.0;
    }

    return PriceOffer(
      productId: (json['product_id'] is num)
          ? (json['product_id'] as num).toInt()
          : int.tryParse(json['product_id']?.toString() ?? '') ?? 0,
      supermarketId: (json['supermarket_id'] is num)
          ? (json['supermarket_id'] as num).toInt()
          : int.tryParse(json['supermarket_id']?.toString() ?? '') ?? 0,
      supermarketName: json['supermarket_name'] as String? ?? '',
      price: price,
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}

class PriceComparison {
  final String barcode;
  final String productName;
  final double minPrice;
  final double maxPrice;
  final double saving;
  final List<PriceOffer> offers;

  PriceComparison({
    required this.barcode,
    required this.productName,
    required this.minPrice,
    required this.maxPrice,
    required this.saving,
    required this.offers,
  });

  factory PriceComparison.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '') ?? 0.0;
    }

    final offersJson = json['price_offers'];
    List<Map<String, dynamic>> offersData;
    if (offersJson is List) {
      offersData = offersJson.cast<Map<String, dynamic>>();
    } else if (offersJson is Map) {
      offersData = [offersJson.cast<String, dynamic>()];
    } else {
      offersData = [];
    }

    final offers = offersData.map((e) => PriceOffer.fromJson(e)).toList();

    return PriceComparison(
      barcode: json['barcode'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      minPrice: parseDouble(json['min_price']),
      maxPrice: parseDouble(json['max_price']),
      saving: parseDouble(json['saving']),
      offers: offers,
    );
  }
}
