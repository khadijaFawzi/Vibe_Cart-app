import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibe_cart/models/category_model.dart';
import 'package:vibe_cart/models/center_model.dart';
import 'package:vibe_cart/models/product_supermarket_model.dart';
import 'package:vibe_cart/models/supermarket.dart';
import 'package:vibe_cart/utils/constants.dart';

class ApiService {
  // ❗ قم بتعديل هذا الرابط ليتوافق مع عنوان السيرفر الخاص بك
  static const String baseUrl = 'http://192.168.1.107:8000/api/customer/supermarkets';

  // 🛒 دالة جلب السوبرماركتات من السيرفر
  static Future<List<SuperMarket>> getSupermarkets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customer/supermarkets'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true && data['supermarkets'] != null) {
          return (data['supermarkets'] as List)
              .map((json) => SuperMarket.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error fetching supermarkets: $e');
      return [];
    }
  }

  // 📦 جلب المنتجات (وهمية)
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(seconds: 1));

    return List.generate(
      10,
      (index) => Product(
        id: index + 1,
        name: 'منتج ${index + 1}',
        description: 'وصف للمنتج رقم ${index + 1}',
        price: (index + 1) * 10.0,
        imageUrl: 'https://via.placeholder.com/500?text=Product+${index + 1}',
        centerId: (index % 4) + 1,
        categoryId: (index % 6) + 1,
        isOffer: index % 3 == 0,
        discountPercentage: index % 3 == 0 ? 15.0 : null,
      ),
    );
  }

  // 🎁 جلب العروض (وهمية)
  Future<List<Product>> getOffers() async {
    await Future.delayed(const Duration(seconds: 1));

    return List.generate(
      5,
      (index) => Product(
        id: index + 20,
        name: 'عرض خاص ${index + 1}',
        description: 'وصف للعرض رقم ${index + 1}',
        price: (index + 5) * 15.0,
        imageUrl: 'https://via.placeholder.com/500?text=Offer+${index + 1}',
        centerId: (index % 4) + 1,
        categoryId: (index % 6) + 1,
        isOffer: true,
        discountPercentage: 20.0 + (index * 5),
      ),
    );
  }

  // 🏬 جلب المراكز التجارية (وهمية)
  Future<List<ShoppingCenter>> getCenters() async {
    await Future.delayed(const Duration(seconds: 1));

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
  }

 

  // 🧾 جلب منتجات فئة معينة (وهمية)
  Future<List<Product>> getCategoryProducts(int categoryId) async {
    await Future.delayed(const Duration(seconds: 1));

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
  }

  // 🏪 جلب منتجات مركز تجاري معين (وهمية)
  Future<List<Product>> getCenterProducts(int centerId) async {
    await Future.delayed(const Duration(seconds: 1));

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
  }

  // 🧾🏪 جلب منتجات فئة في مركز معين (وهمية)
  Future<List<Product>> getCenterCategoryProducts(int centerId, int categoryId) async {
    await Future.delayed(const Duration(seconds: 1));

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
  }

  // ⚖️ مقارنة سعر منتج بين المراكز (وهمية)
  Future<List<Product>> getProductPriceComparison(int productId) async {
    await Future.delayed(const Duration(seconds: 1));

    return List.generate(
      4,
      (index) => Product(
        id: 400 + index,
        name: 'منتج المقارنة',
        description: 'وصف لمنتج المقارنة في المراكز المختلفة',
        price: 50.0 + (index * 5.0),
        imageUrl: 'https://via.placeholder.com/500?text=Comparison+Product',
        centerId: index + 1,
        categoryId: 1,
        isOffer: index == 2,
        discountPercentage: index == 2 ? 10.0 : null,
      ),
    );
  }
}
