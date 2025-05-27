import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vibe_cart/api/api_service.dart';
import 'package:vibe_cart/models/comment.dart';

class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  bool _isLoading = false;
  String _error = '';
  int _likesCount = 0;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get likesCount => _likesCount;

 Future<void> fetchComments(int productId) async {
  _isLoading = true;
  _error = '';
  notifyListeners();

  try {
    final comments = await ApiService().getComments(productId);
    print('Fetched comments: $comments');  // Print the fetched comments for debugging
    _comments = comments;  // Update the comments list with the fetched comments
  } catch (e) {
    _error = 'حدث خطأ أثناء جلب التعليقات';
    print('Error: $e');  // Log the error for debugging
  }

  _isLoading = false;
  notifyListeners();
}



  // جلب عدد الإعجابات
  Future<void> fetchLikes(int commentId) async {
    try {
      final count = await ApiService().likesCount(commentId);
      _likesCount = count;
      notifyListeners();
    } catch (e) {
      _error = 'حدث خطأ أثناء جلب الإعجابات';
      notifyListeners();
    }
  }

  // إضافة تعليق
  Future<void> addComment(int productId, String body, {int? userId}) async {
    try {
      // إرسال التعليق مع user_id (إذا لم يُمرر user_id يتم تعيينه إلى 1)
      await ApiService().addComment(body, productId, userId: userId ?? 1);
      fetchComments(productId); // جلب التعليقات بعد إضافة تعليق جديد
    } catch (e) {
      _error = 'حدث خطأ أثناء إضافة التعليق';
      notifyListeners();
    }
  }

  // إضافة إعجاب أو إلغاء إعجاب
 
Future<void> toggleLike(int commentId, {required int userId}) async {
  try {
    await ApiService().toggleLike(commentId, userId: userId);
    // لا تحدث العداد هنا، دعه فقط لجلب العداد الجديد من الدالة الأخرى
  } catch (e) {
    _error = 'حدث خطأ أثناء تغيير الإعجاب';
    notifyListeners();
  }
}

  Future<int> fetchLikesCount(int commentId) async {
  try {
    final count = await ApiService().likesCount(commentId);
    return count;
  } catch (e) {
    _error = 'حدث خطأ أثناء جلب الإعجابات';
    return 0;
  }
}

}
