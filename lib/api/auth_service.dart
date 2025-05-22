import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;
  
  AuthService({
    ApiService? apiService,
    StorageService? storageService
  }) : 
    _apiService = apiService ?? ApiService(),
    _storageService = storageService ?? StorageService();

  /// تسجيل مستخدم جديد
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.dioInstance.post(
        '/register',
        data: {
          'username'     : username,
          'email'        : email,
          'password'     : password,
          'phone_number' : phoneNumber,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token = data['token'] as String?;
        if (token != null) {
          // حفظ التوكن وتهيئة الهيدر للمستقبل
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          _apiService.setAuthToken(token);
        }
        if (data['user'] != null) {
          await _storageService.saveUserData(data['user']);
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'فشل التسجيل'};
    } on DioError catch (e) {
      String msg = 'خطأ أثناء التسجيل';
      if (e.response != null) {
        final d = e.response!.data;
        msg = d['message'] ?? d['error'] ?? msg;
        if (e.response!.statusCode == 422 && d['errors'] is Map) {
          final first = (d['errors'] as Map).values.first;
          if (first is List && first.isNotEmpty) msg = first.first;
        }
      }
      return {'success': false, 'message': msg};
    }
  }

  /// تسجيل الدخول
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dioInstance.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'] as String?;
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          _apiService.setAuthToken(token);
        }
        if (data['user'] != null) {
          await _storageService.saveUserData(data['user']);
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'فشل تسجيل الدخول'};
    } on DioError catch (e) {
      String msg = 'خطأ أثناء تسجيل الدخول';
      if (e.response?.statusCode == 401) {
        msg = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else if (e.response?.data?['message'] != null) {
        msg = e.response!.data['message'];
      }
      return {'success': false, 'message': msg};
    }
  }

  /// تسجيل الخروج
  Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        _apiService.setAuthToken(token);
        await _apiService.dioInstance.post('/logout');
      }
    } catch (_) {
      // نتجاهل أخطاء الخروج
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _apiService.removeAuthToken();
      await _storageService.deleteUserData();
    }
    return {'success': true};
  }

  /// تحقق من وجود جلسة مستخدم
  Future<bool> isAuthenticated() async {
    final token = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('auth_token'));
    return token != null;
  }

  /// جلب بيانات المستخدم الحالي من التخزين المحلي
  Future<Map<String, dynamic>?> getCurrentUser() async {
    return _storageService.getUserData();
  }
}
