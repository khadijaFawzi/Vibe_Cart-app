import 'package:vibe_cart/models/OrderDetail.dart';

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

class Order {
  final int id;
  final int userId;
  final int supermarketId;
  final String status;
  final double total;
  final double deliveryFee;
  final String paymentStatus;
  final String? depositReceipt;
  final String deliveryStatus;
  final String? trackingCode;
  final List<OrderDetail> orderDetails;
  final String? createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.supermarketId,
    required this.status,
    required this.total,
    required this.deliveryFee,
    required this.paymentStatus,
    this.depositReceipt,
    required this.deliveryStatus,
    this.trackingCode,
    required this.orderDetails,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: parseInt(json['id']),
    userId: parseInt(json['user_id']),
    supermarketId: parseInt(json['supermarket_id']),
    status: json['status'],
    total: parseDouble(json['total']),
    deliveryFee: parseDouble(json['delivery_fee']),
    paymentStatus: json['payment_status'],
    depositReceipt: json['deposit_receipt'],
    deliveryStatus: json['delivery_status'],
    trackingCode: json['tracking_code'],
    orderDetails: (json['order_details'] != null)
        ? (json['order_details'] as List)
            .map((e) => OrderDetail.fromJson(e))
            .toList()
        : [],
    createdAt: json['created_at'],
  );
}
