import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // حفظ الرمز المميز في التخزين الآمن
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }
  
  // الحصول على الرمز المميز من التخزين الآمن
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }
  
  // حذف الرمز المميز من التخزين الآمن
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }
  
  // حفظ بيانات المستخدم في التخزين المحلي
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }
  
  // الحصول على بيانات المستخدم من التخزين المحلي
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }
  
  // حذف بيانات المستخدم من التخزين المحلي
  Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
