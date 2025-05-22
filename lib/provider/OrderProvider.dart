import 'package:flutter/material.dart';
import 'package:vibe_cart/api/api_service.dart';
import 'package:vibe_cart/models/order.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService apiService;

  List<Order> orders = [];
  Order? selectedOrder;
  bool isLoading = false;
 int? lastCreatedOrderId;

  OrderProvider({required this.apiService});

  Future<void> fetchOrders() async {
    isLoading = true;
    notifyListeners();
    orders = await apiService.getMyOrders();
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrderDetails(int orderId) async {
    isLoading = true;
    notifyListeners();
    selectedOrder = await apiService.getOrderDetails(orderId);
    isLoading = false;
    notifyListeners();
  }

  Future<int?> createOrder({
  required int supermarketId,
  required double total,
  required double deliveryFee,
  required List<Map<String, dynamic>> products,
}) async {
  isLoading = true;
  notifyListeners();
  final response = await apiService.placeOrder(
    supermarketId: supermarketId,
    total: total,
    deliveryFee: deliveryFee,
    products: products,
  );
  isLoading = false;
  notifyListeners();

  if (response.statusCode == 200 && response.data['order'] != null) {
    // حسب استجابة الـ API لديك: قد تكون order أو order_id
    lastCreatedOrderId = response.data['order']['id'] ?? response.data['order_id'];
    return lastCreatedOrderId;
  }
  return null;
}



  Future<bool> uploadDeposit(int orderId, String filePath) async {
    isLoading = true;
    notifyListeners();
    final result = await apiService.uploadDepositReceipt(
      orderId: orderId,
      filePath: filePath,
    );
    isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> cancelOrder(int orderId) async {
    isLoading = true;
    notifyListeners();
    final result = await apiService.cancelOrder(orderId);
    isLoading = false;
    notifyListeners();
    return result;
  }
}
