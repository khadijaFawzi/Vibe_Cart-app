import 'package:dio/dio.dart';
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

  // تسجيل مستخدم جديد
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.dioInstance.post(
        '/register', // قم بتغيير هذا المسار حسب API الخاص بك
        data: {
          'username': username,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
        },
      );
      
      // التحقق من نجاح الاستجابة
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // حفظ بيانات المستخدم والرمز المميز
        if (data['token'] != null) {
          await _storageService.saveToken(data['token']);
          
          if (data['user'] != null) {
            await _storageService.saveUserData(data['user']);
          }
        }
        
        return {
          'success': true,
          'message': 'تم التسجيل بنجاح',
          'data': data
        };
      }
      
      return {
        'success': false,
        'message': 'حدث خطأ أثناء التسجيل',
      };
      
    } on DioException catch (e) {
      // التعامل مع أخطاء Dio
      String errorMessage = 'حدث خطأ أثناء التسجيل';
      
      if (e.response != null) {
        // الحصول على رسالة الخطأ من الخادم إن وجدت
        final responseData = e.response?.data;
        if (responseData != null && responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (responseData != null && responseData['error'] != null) {
          errorMessage = responseData['error'];
        }
        
        // التحقق من أخطاء محددة
        if (e.response?.statusCode == 422) {
          // أخطاء التحقق
          final errors = responseData['errors'];
          if (errors != null && errors is Map) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first;
            }
          }
        }
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      // التعامل مع الأخطاء العامة
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: ${e.toString()}',
      };
    }
  }
  
  // تسجيل الدخول
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dioInstance.post(
        '/login', // قم بتغيير هذا المسار حسب API الخاص بك
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // حفظ بيانات المستخدم والرمز المميز
        if (data['token'] != null) {
          await _storageService.saveToken(data['token']);
          
          if (data['user'] != null) {
            await _storageService.saveUserData(data['user']);
          }
          
          // إعداد الرمز المميز للطلبات المستقبلية
          _apiService.setAuthToken(data['token']);
        }
        
        return {
          'success': true,
          'message': 'تم تسجيل الدخول بنجاح',
          'data': data
        };
      }
      
      return {
        'success': false,
        'message': 'حدث خطأ أثناء تسجيل الدخول',
      };
      
    } on DioException catch (e) {
      String errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
      
      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        } else {
          final responseData = e.response?.data;
          if (responseData != null && responseData['message'] != null) {
            errorMessage = responseData['message'];
          }
        }
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: ${e.toString()}',
      };
    }
  }
  
  // تسجيل الخروج
  Future<Map<String, dynamic>> logout() async {
    try {
      // الحصول على الرمز المميز للتحقق من وجود مستخدم مسجل الدخول
      final token = await _storageService.getToken();
      
      if (token != null) {
        // إعداد رأس المصادقة للطلب
        _apiService.setAuthToken(token);
        
        // استدعاء نقطة نهاية تسجيل الخروج في API
        final response = await _apiService.dioInstance.post('/logout');
        
        // تنظيف البيانات المحلية بغض النظر عن استجابة الخادم
        await _clearUserSession();
        
        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': 'تم تسجيل الخروج بنجاح',
          };
        }
      } else {
        // إذا لم يكن هناك رمز مميز، قم بتنظيف البيانات المحلية فقط
        await _clearUserSession();
        
        return {
          'success': true,
          'message': 'تم تسجيل الخروج بنجاح',
        };
      }
      
      return {
        'success': true,
        'message': 'تم تسجيل الخروج بنجاح',
      };
      
    } catch (e) {
      // في حالة حدوث خطأ، قم بتنظيف البيانات المحلية على أي حال
      await _clearUserSession();
      
      return {
        'success': true,
        'message': 'تم تسجيل الخروج بنجاح',
      };
    }
  }
  
  // تنظيف بيانات الجلسة المحلية
  Future<void> _clearUserSession() async {
    await _storageService.deleteToken();
    await _storageService.deleteUserData();
    _apiService.removeAuthToken();
  }
  
  // التحقق من حالة المصادقة
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getToken();
    return token != null;
  }
  
  // الحصول على بيانات المستخدم الحالي
  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await _storageService.getUserData();
  }
}
