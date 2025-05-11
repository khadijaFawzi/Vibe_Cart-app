import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_cart/models/user_model.dart';
 

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String _error = '';
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (isLoggedIn) {
      // استرجاع بيانات المستخدم من التخزين المحلي
      final userData = prefs.getString('userData');
      if (userData != null) {
        try {
          final userMap = Map<String, dynamic>.from({
            'id': prefs.getInt('userId') ?? 1,
            'name': prefs.getString('userName') ?? '',
            'email': prefs.getString('userEmail') ?? '',
            'phone_number': prefs.getString('userPhone') ?? '',
            'profile_image_url': prefs.getString('userImage'),
            'address': prefs.getString('userAddress'),
          });
          
          _currentUser = User.fromJson(userMap);
          _isLoggedIn = true;
          notifyListeners();
        } catch (e) {
          _error = e.toString();
          _isLoggedIn = false;
          notifyListeners();
        }
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // في التطبيق الحقيقي: اتصال بالخادم للتحقق من بيانات الدخول
      await Future.delayed(const Duration(seconds: 2)); // محاكاة الاتصال بالخادم
      
      // افتراض أن الدخول ناجح إذا كان البريد والكلمة صحيحة
      if (email == 'user@example.com' && password == 'password123') {
        // استخدام بيانات وهمية للمستخدم
        _currentUser = User(
          id: 1,
          name: 'مستخدم نموذجي',
          email: email,
          phoneNumber: '0501234567',
          profileImageUrl: 'https://via.placeholder.com/150',
          address: 'حضرموت، اليمن',
        );
        _isLoggedIn = true;
        
        // حفظ حالة الدخول في التخزين المحلي
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('userId', _currentUser!.id);
        await prefs.setString('userName', _currentUser!.name);
        await prefs.setString('userEmail', _currentUser!.email);
        await prefs.setString('userPhone', _currentUser!.phoneNumber);
        if (_currentUser!.profileImageUrl != null) {
          await prefs.setString('userImage', _currentUser!.profileImageUrl!);
        }
        if (_currentUser!.address != null) {
          await prefs.setString('userAddress', _currentUser!.address!);
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String phoneNumber) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // في التطبيق الحقيقي: اتصال بالخادم لتسجيل المستخدم
      await Future.delayed(const Duration(seconds: 2)); // محاكاة الاتصال بالخادم
      
      // افتراض أن التسجيل ناجح دائمًا
      _currentUser = User(
        id: 1,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
      _isLoggedIn = true;
      
      // حفظ حالة الدخول في التخزين المحلي
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('userId', _currentUser!.id);
      await prefs.setString('userName', _currentUser!.name);
      await prefs.setString('userEmail', _currentUser!.email);
      await prefs.setString('userPhone', _currentUser!.phoneNumber);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    // حذف بيانات المستخدم من التخزين المحلي
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userPhone');
    await prefs.remove('userImage');
    await prefs.remove('userAddress');
    
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      // في التطبيق الحقيقي: اتصال بالخادم لتحديث البيانات
      await Future.delayed(const Duration(seconds: 1)); // محاكاة الاتصال بالخادم
      
      // تحديث بيانات المستخدم محليًا
      _currentUser = User(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        address: address ?? _currentUser!.address,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
      );
      
      // تحديث البيانات في التخزين المحلي
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _currentUser!.name);
      await prefs.setString('userEmail', _currentUser!.email);
      await prefs.setString('userPhone', _currentUser!.phoneNumber);
      if (_currentUser!.address != null) {
        await prefs.setString('userAddress', _currentUser!.address!);
      }
      if (_currentUser!.profileImageUrl != null) {
        await prefs.setString('userImage', _currentUser!.profileImageUrl!);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
