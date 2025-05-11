import 'package:flutter/material.dart';
import '../api/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;
  String _error = '';
  
  // الحصول على حالات مختلفة
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userData => _userData;
  String get error => _error;
  
  // التهيئة - التحقق من حالة المصادقة عند بدء التطبيق
  AuthProvider() {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _isAuthenticated = await _authService.isAuthenticated();
      if (_isAuthenticated) {
        _userData = await _authService.getCurrentUser();
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء التحقق من حالة المصادقة';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
 Future<bool> register(String username, String email, String password, String phoneNumber) async {
  _isLoading = true;
  _error = '';
  notifyListeners();

  try {
    final result = await _authService.register(
      username: username,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );

    // اعتبر العملية ناجحة لو result['success'] true أو حتى لو status 200/201
    if (result['success'] || result['data'] != null) {
      _isAuthenticated = true;

      // تحقق إذا فيه بيانات user وخزنها
      if (result['data'] != null && result['data']['user'] != null) {
        _userData = result['data']['user'];
      } else {
        _userData = {};
      }

      return true;
    } else {
      _error = result['message'] ?? 'حدث خطأ أثناء التسجيل';
      return false;
    }
  } catch (e) {
    _error = 'حدث خطأ أثناء التسجيل: ${e.toString()}';
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
}
}

  
  // تسجيل الدخول
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );
      
      if (result['success']) {
        _isAuthenticated = true;
        _userData = result['data']['user'];
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تسجيل الدخول: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // تسجيل الخروج
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
      _isAuthenticated = false;
      _userData = null;
    } catch (e) {
      _error = 'حدث خطأ أثناء تسجيل الخروج: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
