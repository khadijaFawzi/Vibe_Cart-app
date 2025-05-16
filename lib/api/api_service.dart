// // // lib/services/api_service.dart

// import 'package:dio/dio.dart';
// import '../models/supermarket.dart';

// class ApiService {
//   final Dio _dio;

//   ApiService({
//     String baseUrl = 'http://192.168.1.107:8000/api',
//   }) : _dio = Dio(BaseOptions(
//           baseUrl: baseUrl,
//           connectTimeout: const Duration(seconds: 5),
//           receiveTimeout: const Duration(seconds: 3),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//         )) {
//     _dio.interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) {
//         print('DIO REQUEST → [\${options.method}] \${options.baseUrl}\${options.path}');
//         return handler.next(options);
//       },
//       onResponse: (response, handler) {
//         print('DIO RESPONSE ← [\${response.statusCode}] \${response.requestOptions.path}');
//         return handler.next(response);
//       },
//       onError: (DioError err, handler) {
//         print('DIO ERROR   × [\${err.response?.statusCode}] \${err.requestOptions.path} → \${err.message}');
//         return handler.next(err);
//       },
//     ));
//   }

//   /// alias قديم لتمكين dioInstance()
//   Dio get dioInstance => _dio;

//   /// getter جديد للوصول إلى Dio
//   Dio get client => _dio;

//   /// جلب قائمة السوبرماركتات
//   Future<List<SuperMarket>> getSupermarkets() async {
//     try {
//       final response = await _dio.get('/customer/supermarkets');
//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data['status'] == true && data['supermarkets'] != null) {
//           return (data['supermarkets'] as List)
//               .map((json) => SuperMarket.fromJson(json))
//               .toList();
//         }
//       }
//       return [];
//     } on DioError catch (e) {
//       print('Error fetching supermarkets: \${e.message}');
//       return [];
//     } catch (e) {
//       print('Unexpected error: \$e');
//       return [];
//     }
//   }

//   /// إضافة أو إزالة توكين المصادقة
//   void setAuthToken(String token) {
//     _dio.options.headers['Authorization'] = 'Bearer \$token';
//   }

//   void removeAuthToken() {
//     _dio.options.headers.remove('Authorization');
//   }
// }
















import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:vibe_cart/models/category_model.dart';
import '../models/supermarket.dart';

class ApiService {
  // هنا فقط /api وليس endpoint كامل
  static const String baseUrl = 'http://192.168.1.107:8000/api';

  final Dio _dio;
  final http.Client _httpClient;

  ApiService({ http.Client? httpClient })
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),  // ↑ رفع زمن الاتصال
        receiveTimeout: Duration.zero,  // ↑ رفع زمن استقبال البيانات
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )),
        _httpClient = httpClient ?? http.Client() {
    // Logging interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, h) {
        print('DIO REQUEST → [${opts.method}] ${opts.baseUrl}${opts.path}');
        return h.next(opts);
      },
      onResponse: (res, h) {
        print('DIO RESPONSE ← [${res.statusCode}] ${res.requestOptions.path}');
        return h.next(res);
      },
      onError: (e, h) {
        print('DIO ERROR   × [${e.response?.statusCode}] '
              '${e.requestOptions.path} → ${e.message}');
        return h.next(e);
      },
    ));
  }

  /// الطريقة القديمة باستخدام http
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
      return [];
    } catch (e) {
      print('HTTP error fetching supermarkets: $e');
      return [];
    }
  }

  /// الطريقة الافتراضية باستخدام Dio
  Future<List<SuperMarket>> getSupermarkets() async {
    try {
      final response = await _dio.get('/customer/supermarkets');
       print('🔍 [DIO RAW RESPONSE] status=${response.statusCode}, body=${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true && data['supermarkets'] != null) {
          return (data['supermarkets'] as List)
              .map((j) => SuperMarket.fromJson(j))
              .toList();
        }
      }
      return [];
    } on DioError catch (e) {
      print('Dio error fetching supermarkets: ${e.message}');
      return [];
    } catch (e) {
      print('Unexpected error: $e');
      return [];
    }
  }

  /// Getters للـ Dio لو احتجتَ تستخدم dioInstance أو client
  Dio get dioInstance => _dio;
  Dio get client      => _dio;

  /// إدارة توكين المصادقة
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }


    Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200 && response.data['status'] == true) {
        final list = response.data['categories'] as List;
        return list.map((j) => Category.fromJson(j)).toList();
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
    return [];
  }
}


