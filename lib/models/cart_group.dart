import 'package:vibe_cart/models/cart_item.dart';

class CartGroup {
  /// رقم السوبرماركت
  final int supermarketId; // << أضف هذا
  final String supermarket;
  final double subtotal;
  final List<CartItem> items;

  CartGroup({
    required this.supermarketId, // << هنا أيضًا
    required this.supermarket,
    required this.subtotal,
    required this.items,
  });

  factory CartGroup.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val is double) return val;
      if (val is num)    return val.toDouble();
      return double.tryParse(val?.toString() ?? '') ?? 0.0;
    }

    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return CartGroup(
      supermarketId: json['supermarket_id'] ?? 0, // << هنا
      supermarket: json['supermarket']?.toString() ?? '',
      subtotal:    parseDouble(json['subtotal']),
      items:       items,
    );
  }
}
