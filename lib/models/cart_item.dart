// lib/models/cart_item.dart

class CartItem {
  final int id;
  final int productId;
  final String productName;
  final int supermarketId;
  final String supermarketName;
  final int quantity;
  final double price;
  final double total;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.supermarketId,
    required this.supermarketName,
    required this.quantity,
    required this.price,
    required this.total,
    required this.imageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val is double) return val;
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '') ?? 0.0;
    }

    return CartItem(
      id: parseInt(json['id']),
      productId: parseInt(json['product_id']),
      productName: json['product_name']?.toString() ?? '',
      supermarketId: parseInt(json['supermarket_id']),
      supermarketName: json['supermarket']?.toString() ?? '',
      quantity: parseInt(json['quantity']),
      price: parseDouble(json['price']),
      total: parseDouble(json['total']),
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }
}