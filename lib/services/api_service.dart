

import 'package:vibe_cart/models/category_model.dart';
import 'package:vibe_cart/models/center_model.dart';
import 'package:vibe_cart/models/product_model.dart';
import 'package:vibe_cart/utils/constants.dart';

class ApiService {
  // في حالة عدم وجود API فعلي، سنستخدم بيانات وهمية للتطوير
  static const String baseUrl = 'https://api.example.com/vibecart'; // API وهمي

  // جلب المنتجات
  Future<List<Product>> getProducts() async {
    try {
      // محاكاة طلب API
      // في التطبيق الفعلي، هذه ستكون: await http.get(Uri.parse('$baseUrl/products'));
      await Future.delayed(const Duration(seconds: 1)); // تأخير وهمي
      
      // إرجاع بيانات وهمية
      return List.generate(
        10,
        (index) => Product(
          id: index + 1,
          name: 'منتج ${index + 1}',
          description: 'وصف للمنتج رقم ${index + 1}، تفاصيل إضافية عن المنتج وخصائصه المختلفة',
          price: (index + 1) * 10.0,
          imageUrl: 'https://via.placeholder.com/500?text=Product+${index + 1}',
          centerId: (index % 4) + 1,
          categoryId: (index % 6) + 1,
          isOffer: index % 3 == 0,
          discountPercentage: index % 3 == 0 ? 15.0 : null,
        ),
      );
    } catch (e) {
      throw Exception('فشل في جلب المنتجات: $e');
    }
  }

  // جلب العروض
  Future<List<Product>> getOffers() async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // تأخير وهمي
      
      return List.generate(
        5,
        (index) => Product(
          id: index + 20,
          name: 'عرض خاص ${index + 1}',
          description: 'وصف للعرض رقم ${index + 1}، عرض محدود لفترة زمنية قصيرة',
          price: (index + 5) * 15.0,
          imageUrl: 'https://via.placeholder.com/500?text=Offer+${index + 1}',
          centerId: (index % 4) + 1,
          categoryId: (index % 6) + 1,
          isOffer: true,
          discountPercentage: 20.0 + (index * 5),
        ),
      );
    } catch (e) {
      throw Exception('فشل في جلب العروض: $e');
    }
  }

  // جلب المراكز التجارية
  Future<List<ShoppingCenter>> getCenters() async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // تأخير وهمي
      
      return List.generate(
        4,
        (index) => ShoppingCenter(
          id: index + 1,
          name: AppConstants.centers[index]['name'],
          logoUrl: 'https://via.placeholder.com/150?text=${AppConstants.centers[index]['name']}',
          description: 'مركز تجاري في حضرموت يقدم مجموعة متنوعة من المنتجات الغذائية',
          address: 'حضرموت، اليمن',
          phoneNumber: '+967700000${index + 1}',
        ),
      );
    } catch (e) {
      throw Exception('فشل في جلب المراكز التجارية: $e');
    }
  }

  // جلب الفئات
  Future<List<Category>> getCategories() async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // تأخير وهمي
      
      return AppConstants.categories.map((cat) => Category(
        id: cat['id'],
        name: cat['name'],
        icon: cat['icon'],
      )).toList();
    } catch (e) {
      throw Exception('فشل في جلب الفئات: $e');
    }
  }

  // جلب منتجات فئة معينة
  Future<List<Product>> getCategoryProducts(int categoryId) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // تأخير وهمي
      
      return List.generate(
        8,
        (index) => Product(
          id: 100 + index,
          name: 'منتج ${index + 1} من الفئة $categoryId',
          description: 'وصف للمنتج رقم ${index + 1} من الفئة $categoryId',
          price: (index + 3) * 8.0,
          imageUrl: 'https://via.placeholder.com/500?text=Category+$categoryId+Product+${index + 1}',
          centerId: (index % 4) + 1,
          categoryId: categoryId,
          isOffer: index % 4 == 0,
          discountPercentage: index % 4 == 0 ? 10.0 : null,
        ),
      );
    } catch (e) {
      throw Exception('فشل في جلب منتجات الفئة: $e');
    }
  }

  // جلب منتجات مركز تجاري معين
  Future<List<Product>> getCenterProducts(int centerId) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // تأخير وهمي
      
      return List.generate(
        12,
        (index) => Product(
          id: 200 + index,
          name: 'منتج ${index + 1} من المركز $centerId',
          description: 'وصف للمنتج رقم ${index + 1} من المركز $centerId',
          price: (index + 2) * 12.0,
          imageUrl: 'https://via.placeholder.com/500?text=Center+$centerId+Product+${index + 1}',
          centerId: centerId,
          categoryId: (index % 6) + 1,
          isOffer: index % 5 == 0,
          discountPercentage: index % 5 == 0 ? 15.0 : null,
        ),
      );
    } catch (e) {
      throw Exception('فشل في جلب منتجات المركز: $e');
    }
  }

  // جلب منتجات فئة معينة في مركز معين
  Future<List<Product>> getCenterCategoryProducts(int centerId, int categoryId) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // تأخير وهمي
      
      return List.generate(
        6,
        (index) => Product(
          id: 300 + index,
          name: 'منتج ${index + 1} من الفئة $categoryId في المركز $centerId',
          description: 'وصف للمنتج رقم ${index + 1} من الفئة $categoryId في المركز $centerId',
          price: (index + 1) * 14.0,
          imageUrl: 'https://via.placeholder.com/500?text=Center+$centerId+Category+$categoryId+Product+${index + 1}',
          centerId: centerId,
          categoryId: categoryId,
          isOffer: index % 6 == 0,
          discountPercentage: index % 6 == 0 ? 12.0 : null,
        ),
      );
    } catch (e) {
      throw Exception('فشل في جلب منتجات الفئة في المركز: $e');
    }
  }

  // جلب مقارنة سعر منتج بين المراكز المختلفة
  Future<List<Product>> getProductPriceComparison(int productId) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // تأخير وهمي
      
      // افتراض أننا نقارن نفس المنتج في 4 مراكز مختلفة
      String productName = 'منتج المقارنة';
      String productDescription = 'وصف لمنتج المقارنة في المراكز المختلفة';
      
      return List.generate(
        4,
        (index) => Product(
          id: 400 + index,
          name: productName,
          description: productDescription,
          price: 50.0 + (index * 5.0), // سعر مختلف في كل مركز
          imageUrl: 'https://via.placeholder.com/500?text=Comparison+Product',
          centerId: index + 1,
          categoryId: 1,
          isOffer: index == 2, // عرض في المركز الثالث فقط
          discountPercentage: index == 2 ? 10.0 : null,
        ),
      );
    } catch (e) {
      throw Exception('فشل في جلب مقارنة الأسعار: $e');
    }
  }
}
