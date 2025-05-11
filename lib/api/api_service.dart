import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  
  // قم بتغيير هذا الرابط إلى عنوان API الخاص بالباك إند الخاص بك
  static const String baseUrl = 'http://192.168.1.107:8000/api';
  // يمكن أن يكون URL المحلي للتطوير: http://10.0.2.2:8000/api (لمحاكي Android)
  // أو http://localhost:8000/api (للتطوير المحلي)
  
  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // إضافة مُعترض للتعامل مع الأخطاء
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        print('DIO ERROR: ${error.message}');
        return handler.next(error);
      },
      onRequest: (request, handler) {
        print('DIO REQUEST: ${request.method} ${request.path}');
        return handler.next(request);
      },
      onResponse: (response, handler) {
        print('DIO RESPONSE: ${response.statusCode}');
        return handler.next(response);
      },
    ));
  }
  
  // الحصول على مثيل Dio للاستخدام في خدمات أخرى
  Dio get dioInstance => _dio;
  
  // إضافة رمز مميز للمصادقة إلى الرأس
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  // إزالة رمز المصادقة من الرأس
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
