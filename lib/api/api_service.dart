// lib/api/api_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_cart/models/order.dart';
import 'package:vibe_cart/models/bank_account.dart';

import 'package:vibe_cart/models/cart_group.dart';
import 'package:vibe_cart/models/category_model.dart';
import 'package:vibe_cart/models/favorite_item.dart';
import 'package:vibe_cart/models/offer.dart';
import 'package:vibe_cart/models/price_comparison.dart';
import 'package:vibe_cart/models/product.dart';
import 'package:vibe_cart/models/supermarket.dart';

class ApiService {
  /// أساس المسارات في الـ API
  static const String baseUrl = 'http://192.168.1.107:8000/api';

  final Dio _dio;
  final http.Client _httpClient;

  ApiService({ http.Client? httpClient })
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )),
        _httpClient = httpClient ?? http.Client() {
    // تسجيل الطلبات والاستجابات
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('DIO REQUEST → [${options.method}] ${options.baseUrl}${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('DIO RESPONSE ← [${response.statusCode}] ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('DIO ERROR   × [${error.response?.statusCode}] '
              '${error.requestOptions.path} → ${error.message}');
        return handler.next(error);
      },
    ));

    // إضافة هيدر Authorization تلقائياً إن وُجد التوكن
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  /// (الطريقة القديمة) جلب السوبرماركتات باستخدام http.Client
  Future<List<SuperMarket>> getSupermarketsHttp() async {
    final uri = Uri.parse('$baseUrl/customer/supermarkets');
    try {
      final response = await _httpClient.get(uri, headers: {
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['supermarkets'] != null) {
          return (data['supermarkets'] as List)
              .map((j) => SuperMarket.fromJson(j))
              .toList();
        }
      }
    } catch (e) {
      print('HTTP error fetching supermarkets: $e');
    }
    return [];
  }

  /// جلب السوبرماركتات باستخدام Dio
  Future<List<SuperMarket>> getSupermarkets() async {
    try {
      final response = await _dio.get('/customer/supermarkets');
      if (response.statusCode == 200 && response.data['status'] == true) {
        return (response.data['supermarkets'] as List)
            .map((j) => SuperMarket.fromJson(j))
            .toList();
      }
    } on DioError catch (e) {
      print('Dio error fetching supermarkets: ${e.message}');
    }
    return [];
  }

 Future<List<Category>> getCategories() async {
  try {
    final response = await _dio.get('/categories'); // استخدم رابط الفئات الصحيح
    if (response.statusCode == 200 && response.data['status'] == true) {
      return (response.data['categories'] as List)
          .map((j) => Category.fromJson(j))
          .toList();
    }
  } catch (e) {
    print('Error fetching categories: $e');
  }
  return [];
}
Future<List<Product>> getProductsByCategory(int categoryId) async {
  try {
    final response = await _dio.get('/categories/$categoryId/products');
    if (response.statusCode == 200 && response.data['status'] == true) {
      return (response.data['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    }
  } catch (e) {
    print('Error fetching products by category: $e');
  }
  return [];
}


  Future<List<Product>> getProductsBySupermarket(int supermarketId) async {
    try {
      final response = await _dio.get('/customer/supermarkets/$supermarketId/products');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => Product.fromJson(json)).toList();
        } else if (data is Map && data['products'] != null) {
          return (data['products'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching products for supermarket $supermarketId: $e');
    }
    return [];
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _dio.get('/customer/products');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => Product.fromJson(json)).toList();
        } else if (data is Map && data['products'] != null) {
          return (data['products'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching all products: $e');
    }
    return [];
  }

  Future<PriceComparison> compareByBarcode(String barcode) async {
    final resp = await _dio.get('/customer/products/barcode/$barcode/compare');
    if (resp.statusCode == 200 && resp.data['status'] == true) {
      return PriceComparison.fromJson(resp.data);
    }
    throw Exception(resp.data['message'] ?? 'خطأ في المقارنة');
  }

  Future<List<Offer>> getOffers() async {
    try {
      final response = await _dio.get('/customer/offers');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((j) => Offer.fromJson(j)).toList();
        } else if (data is Map && data['offers'] != null) {
          return (data['offers'] as List)
              .map((j) => Offer.fromJson(j))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching offers: $e');
    }
    return <Offer>[];
  }

 /// 1. جلب محتويات السلة
Future<List<CartGroup>> getCart() async {
  final resp = await _dio.get('/customer/cart');
  final data = resp.data['groups'] as List<dynamic>;
  return data.map((g) => CartGroup.fromJson(g)).toList();
}
  /// جلب منتج واحد بالباركود
  Future<Product> getProductByBarcode(String barcode) async {
    final resp = await _dio.get('/customer/products/barcode/$barcode');
    if (resp.statusCode == 200 && resp.data['status'] == true) {
      return Product.fromJson(resp.data['product']);
    }
    throw Exception('فشل جلب المنتج بالباركود');
  }
/// 2. إضافة منتج إلى السلة
Future<void> addToCart(int productId, int supermarketId, int quantity) async {
  print('→ Sending to cart: productId=$productId, supermarketId=$supermarketId, quantity=$quantity');
  try {
    await _dio.post(
      '/customer/cart',
      data: {
        'product_id': productId,
        'supermarket_id': supermarketId,
        'quantity': quantity,
      },
    );
  } on DioError catch (e) {
    // اطبعي هنا تفاصيل الاستجابة من السيرفر
    if (e.response != null) {
      print('addToCart failed → '
          'status=${e.response?.statusCode} '
          'data=${e.response?.data}');
    } else {
      print('addToCart error → ${e.message}');
    }
    rethrow; // أو تعاملي معها كما تريدين
  }
}


/// 3. تحديث كمية عنصر
Future<void> updateCart(int cartItemId, int quantity) async {
  await _dio.put(
    '/customer/cart/$cartItemId',   // <— صار بدون `/update`
    data: {'quantity': quantity},
  );
}

/// 4. إزالة عنصر
Future<void> removeFromCart(int cartItemId) async {
  await _dio.delete(
    '/customer/cart/$cartItemId',    // <— صار بدون `/remove`
  );
}

/// 5. تفريغ كامل السلة
Future<void> clearCart(int supermarketId) async {
  await _dio.delete('/customer/cart/clear/$supermarketId');
}

  /// المفضلات
  Future<List<FavoriteItem>> getFavorites() async {
    final resp = await _dio.get('/favorites');
    if (resp.statusCode == 200) {
      return (resp.data as List)
          .map((j) => FavoriteItem.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<bool> addFavorite(int productId) async {
    try {
      final resp = await _dio.post('/favorites', data: {'product_id': productId});
      return resp.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeFavorite(int productId) async {
    try {
      final resp = await _dio.delete('/favorites/$productId');
      return resp.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // ========================
  // إدارة توكن المصادقة
  // ========================

  /// يضبط هيدر Authorization يدوياً
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// يزيل هيدر Authorization
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// الوصول المباشر لـ Dio
  Dio get dioInstance => _dio;



  // 1. إرسال طلب جديد (سوبرماركت واحد)
Future<Response> placeOrder({
  required int supermarketId,
  required double total,
  required double deliveryFee,
  required List<Map<String, dynamic>> products,
}) async {
  final data = {
    'supermarket_id': supermarketId,
    'total': total,
    'delivery_fee': deliveryFee,
    'products': products,
  };

  try {
    final response = await _dio.post('/orders', data: data);
    print('DIO ORDER RESPONSE: ${response.data}');
    return response;
  } catch (e) {
    if (e is DioException && e.response != null) {
      print('DIO ORDER ERROR BODY: ${e.response?.data}');
    }
    rethrow;
  }
}


// 2. جلب جميع الطلبات للمستخدم
Future<List<Order>> getMyOrders() async {
  final resp = await _dio.get('/orders');
  if (resp.statusCode == 200 && resp.data['status'] == true) {
    return (resp.data['orders'] as List)
        .map((e) => Order.fromJson(e))
        .toList();
  }
  return [];
}

// 3. جلب تفاصيل طلب محدد
Future<Order?> getOrderDetails(int orderId) async {
  final resp = await _dio.get('/orders/$orderId');
  if (resp.statusCode == 200 && resp.data['status'] == true) {
    return Order.fromJson(resp.data['order']);
  }
  return null;
}

// 4. رفع سند الإيداع
Future<bool> uploadDepositReceipt({
  required int orderId,
  required String filePath,
}) async {
  final formData = FormData.fromMap({
    'deposit_receipt': await MultipartFile.fromFile(filePath),
  });
  final resp = await _dio.post('/orders/$orderId/deposit', data: formData);
  return resp.statusCode == 200 && resp.data['status'] == true;
}

// 5. جلب الحسابات البنكية للسوبرماركت
Future<List<BankAccount>> getSupermarketBankAccounts(int supermarketId) async {
  final resp = await _dio.get('/supermarkets/$supermarketId/bank-accounts');
  print('RESPONSE BANK: ${resp.data}');
  if (resp.statusCode == 200 && resp.data['status'] == true) {
    return (resp.data['accounts'] as List)
        .map((e) => BankAccount.fromJson(e))
        .toList();
  }
  return [];
}


// 6. إلغاء الطلب
Future<bool> cancelOrder(int orderId) async {
  final resp = await _dio.put('/orders/$orderId/cancel');
  return resp.statusCode == 200 && resp.data['status'] == true;
}





}
