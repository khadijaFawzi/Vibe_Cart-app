// lib/api/api_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_cart/models/comment.dart';
import 'package:vibe_cart/models/food_basket.dart';
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
// جلب فئات سوبرماركت معين
Future<List<Category>> getCategoriesBySupermarket(int supermarketId) async {
  try {
    final response = await _dio.get('/supermarkets/$supermarketId/categories');
    if (response.statusCode == 200 && response.data['status'] == true) {
      final list = response.data['categories'] as List;
      return list.map((j) => Category.fromJson(j)).toList();
    }
  } catch (e) {
    print('Error fetching categories by supermarket: $e');
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
/// جلب المنتجات حسب السوبرماركت والفئة
Future<List<Product>> getProductsBySupermarketAndCategory(int supermarketId, int categoryId) async {
  try {
    final response = await _dio.get(
      '/customer/supermarkets/$supermarketId/categories/$categoryId/products',
    );
    if (response.statusCode == 200 && response.data['status'] == true) {
      final list = response.data['products'] as List;
      return list.map((j) => Product.fromJson(j)).toList();
    }
  } catch (e) {
    print('Error fetching products by supermarket and category: $e');
  }
  return [];
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
/// جلب العروض الخاصة بسوبرماركت معين
Future<List<Offer>> getOffersBySupermarket(int supermarketId) async {
  try {
    final response = await _dio.get('/customer/supermarkets/$supermarketId/offers');
    if (response.statusCode == 200 && response.data['status'] == true) {
      final list = response.data['offers'] as List;
      return list.map((j) => Offer.fromJson(j)).toList();
    }
  } catch (e) {
    print('Error fetching offers by supermarket: $e');
  }
  return [];
}  

Future<List<Product>> getSimilarProducts(int productId) async {
  try {
    final response = await Dio().get(
      'http://192.168.1.107:8000/api/customer/products/$productId/similar',
    );
    if (response.statusCode == 200 && response.data['status'] == true) {
      return (response.data['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    }
  } catch (e) {
    print('Error fetching similar products: $e');
  }
  return [];
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
  /// جلب جميع السلات الغذائية لسوبرماركت معين
  Future<List<FoodBasket>> getFoodBasketsBySupermarket(int supermarketId) async {
    try {
      final response = await _dio.get('/supermarkets/$supermarketId/food-baskets');
      if (response.statusCode == 200 &&
          response.data['status'] == true &&
          response.data['data'] != null) {
        final List<dynamic> list = response.data['data'];
        return list.map((j) => FoodBasket.fromJson(j)).toList();
      }
    } catch (e) {
      print('Error fetching food baskets: $e');
    }
    return [];
  }
Future<List<FoodBasket>> getAllFoodBaskets() async {
  final resp = await _dio.get('/food-baskets');
  print('All Food Baskets response: ${resp.data}');
  if (resp.statusCode == 200 && resp.data['status'] == true) {
    final list = resp.data['data'] as List;
    return list.map((j) => FoodBasket.fromJson(j)).toList();
  }
  return [];
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

 
  /// 1. جلب قائمة المفضّلات مع دعم الفلاتر
  Future<List<FavoriteItem>> getFavorites({
    String? type,           // 'product' أو 'offer'
    int? supermarketId,
    String? fromDate,       // بالشكل 'YYYY-MM-DD'
    String? toDate,         // بالشكل 'YYYY-MM-DD'
  }) async {
    final resp = await _dio.get(
      '/favorites',
      queryParameters: {
        if (type != null) 'type': type,
        if (supermarketId != null) 'supermarket_id': supermarketId,
        if (fromDate != null) 'from_date': fromDate,
        if (toDate   != null) 'to_date': toDate,
      },
    );

    if (resp.statusCode == 200) {
      final data = resp.data['data'] as List;
      return data
          .map((j) => FavoriteItem.fromJson(j as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// 2. إضافة عنصر إلى المفضّلات
  Future<bool> addFavorite({
    required String type,        // 'product' أو 'offer'
    required int   favoritableId,
  }) async {
    try {
      final resp = await _dio.post(
        '/favorites',
        data: {
          'type': type,
          if (type == 'product') 'product_id': favoritableId,
          if (type == 'offer'  ) 'offer_id'  : favoritableId,
        },
      );
      return resp.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// 3. إزالة عنصر من المفضّلات
  ///
  /// إذا اعتمدت DELETE /api/favorites/{favoriteId}
  Future<bool> removeFavoriteByRecord(int favoriteId) async {
    try {
      final resp = await _dio.delete('/favorites');
      return resp.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  /// 3. بديل: إزالة عبر DELETE /api/favorites مع body يحتوي type و id
  Future<bool> removeFavorite({
    required String type,        // 'product' أو 'offer'
    required int   favoritableId,
  }) async {
    try {
      final resp = await _dio.delete(
        '/favorites',
        data: {
          'type': type,
          'id'  : favoritableId,
        },
      );
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



  // جلب التعليقات حسب المنتج أو السلة الغذائية
Future<List<Comment>> getComments(int productId, {int? foodBasketId}) async {
  try {
    final response = await _dio.get('/comments', queryParameters: {
      'product_id': productId,  // أو food_basket_id
      if (foodBasketId != null) 'food_basket_id': foodBasketId,
    });

    print('Response data: ${response.data}');  // Print the full response for debugging

    if (response.statusCode == 200 && response.data['status'] == true) {
      return (response.data['comments'] as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    }
  } catch (e) {
    print('Error fetching comments: $e');
  }
  return [];
}



// إضافة تعليق
Future<void> addComment(String body, int productId, {int? userId}) async {
  try {
    final response = await Dio().post(
      'http://192.168.1.107:8000/api/comments',
      data: {
        'body': body,
        'product_id': productId,
        'user_id': userId ?? 1,  // إذا لم يتم تمرير user_id، سيتم تعيينه إلى 1 افتراضيًا
      },
    );

    if (response.statusCode == 200 && response.data['status'] == true) {
      print('Comment added successfully');
    } else {
      print('Failed to add comment');
    }
  } catch (e) {
    print('Error adding comment: $e');
  }
}

// جلب التعليقات الخاصة بمنتج معين
Future<void> fetchComments(int productId) async {
  try {
    final response = await Dio().get(
      'http://192.168.1.107:8000/api/comments',
      queryParameters: {
        'product_id': productId,  // أو food_basket_id
      },
    );

    if (response.statusCode == 200 && response.data['status'] == true) {
      List<Comment> comments = (response.data['comments'] as List)
          .map((e) => Comment.fromJson(e))
          .toList();
      // عرض التعليقات
      print(comments);
    } else {
      print('Failed to load comments');
    }
  } catch (e) {
    print('Error fetching comments: $e');
  }
}


  
Future<int> likesCount(int commentId) async {
  final response = await Dio().get(
    'http://192.168.1.107:8000/api/customer/comments/$commentId/likes',
  );
  if (response.statusCode == 200 && response.data['status'] == true) {
    return response.data['count'] ?? 0;
  }
  return 0;
}

 Future<void> toggleLike(int commentId, {required int userId}) async {
    await Dio().post(
      'http://192.168.1.107:8000/api/customer/comments/$commentId/like',
      data: {'user_id': userId},
    );
  }
Future<int> fetchReviewsCount(int productId) async {
  final url = Uri.parse('http://192.168.1.107:8000/api/products/$productId/reviews/count');
  final response = await http.get(url, headers: {
    'Accept': 'application/json',
    // إذا كان ال API يتطلب توكن للمصادقة أضفه هنا:
    //'Authorization': 'Bearer $token',
  });

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['count'] ?? 0;
  } else {
    throw Exception('Failed to fetch reviews count');
  }
}

Future<void> rateProduct(int productId, int rating, {required String token}) async {
  final url = Uri.parse('http://192.168.1.107:8000/api/products/$productId/reviews');

  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Requested-With': 'XMLHttpRequest', // <-- أضف هذا السطر هنا
    },
    body: {'rating': rating.toString()},
  );

  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');

  if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception('فشل في إرسال التقييم');
  }

}




}
