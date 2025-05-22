// ضع هذه الدوال مرة واحدة فقط في أعلى الملف أو ملف منفصل:
double parseDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class OrderDetail {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
    id: parseInt(json['id']),
    orderId: parseInt(json['order_id']),
    productId: parseInt(json['product_id']),
    quantity: parseInt(json['quantity']),
    price: parseDouble(json['price']),
  );
}
