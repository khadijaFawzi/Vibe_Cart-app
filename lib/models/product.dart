// // lib/models/product.dart
// class Product {
//   final int id;
//   final String name;
//   final double price;
//   final String imageUrl;
//   final String category;
//   final String supermarket;
//   final String barcode;
//   final String description;

//   Product({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.imageUrl,
//     required this.category,
//     required this.supermarket,
//     required this.barcode,
//     required this.description,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'],
//       name: json['name'],
//       price: (json['price'] as num).toDouble(),
//       imageUrl: json['image_url'],
//       category: json['category'],
//       supermarket: json['supermarket'],
//       barcode: json['barcode'] ?? '',
//       description: json['description'] ?? '',
//     );
//   }
// }
// lib/models/product.dart

// class Product {
//   final int id;
//   final String name;
//   final String description;
//   final double price;
//   final String imageUrl;
//   final int? centerId;           // id of center or supermarket if provided
//   final int? categoryId;         // id of category if provided
//   final String? categoryName;    // category name
//   final String? supermarketName; // name of supermarket or center
//   final String barcode;
//   final bool isOffer;
//   final double? discountPercentage;

//   Product({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.imageUrl,
//     this.centerId,
//     this.categoryId,
//     this.categoryName,
//     this.supermarketName,
//     this.barcode = '',
//     this.isOffer = false,
//     this.discountPercentage,
//   });

//   /// السعر بعد تطبيق الخصم إن وجد
//   double get discountedPrice {
//     if (isOffer && discountPercentage != null) {
//       return price - (price * discountPercentage! / 100);
//     }
//     return price;
//   }

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'] as int,
//       name: (json['name'] as String?) ?? '',
//       description: (json['description'] as String?) ?? '',
//       price: (json['price'] is num)
//           ? (json['price'] as num).toDouble()
//           : double.tryParse(json['price'].toString()) ?? 0.0,
//       imageUrl: (json['image_url'] as String?) ?? '',
//       centerId: json['center_id'] as int?,
//       categoryId: json['category_id'] as int?,
//       categoryName: json['category'] as String?,
//       supermarketName: json['supermarket'] as String?,
//       barcode: (json['barcode'] as String?) ?? '',
//       isOffer: json['is_offer'] as bool? ?? false,
//       discountPercentage: json['discount_percentage'] != null
//           ? ((json['discount_percentage'] is num)
//               ? (json['discount_percentage'] as num).toDouble()
//               : double.tryParse(json['discount_percentage'].toString()))
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'price': price,
//       'image_url': imageUrl,
//       if (centerId != null) 'center_id': centerId,
//       if (categoryId != null) 'category_id': categoryId,
//       if (categoryName != null) 'category': categoryName,
//       if (supermarketName != null) 'supermarket': supermarketName,
//       'barcode': barcode,
//       'is_offer': isOffer,
//       'discount_percentage': discountPercentage,
//     };
//   }
// }





// lib/models/product_model.dart
class Product {
  final int id;
  final String productName;
  final String barcode;             // لإضافة حقل الباركود
  final double price;
  final int categoryId;
  final String description;
  final String image;
  final int supermarketId;
  final bool isOffer;               // اختياري لتحديد ما إذا كان المنتج عرضًا

  Product({
    required this.id,
    required this.productName,
    required this.barcode,
    required this.price,
    required this.categoryId,
    required this.description,
    required this.image,
    required this.supermarketId,
    this.isOffer = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // محاولة قراءة المفاتيح بالصيغتين العربية والإنجليزية، مع قيم افتراضية
    final id = (json['id'] as num?)?.toInt() ?? 0;
    final name = (json['product_name'] as String?)
            ?? (json['name'] as String?)
            ?? '';
    final barcode = (json['barcode'] as String?) ?? '';
    final priceValue = json['Price'] != null
        ? double.tryParse(json['Price'].toString())
        : (json['price'] is num
            ? (json['price'] as num).toDouble()
            : double.tryParse(json['price']?.toString() ?? ''));
    final price = priceValue ?? 0.0;
    final categoryId = (json['Category_id'] as num?)?.toInt() ?? 0;
    final description = (json['Description'] as String?)
            ?? (json['description'] as String?)
            ?? '';
    final image = (json['Image'] as String?)
            ?? (json['image_url'] as String?)
            ?? '';
    final supermarketId = (json['supermarket_id'] as num?)?.toInt() ?? 0;
    final isOffer = json['is_offer'] == 1 || json['is_offer'] == true;

    return Product(
      id: id,
      productName: name,
      barcode: barcode,
      price: price,
      categoryId: categoryId,
      description: description,
      image: image,
      supermarketId: supermarketId,
      isOffer: isOffer,
    );
  }
}
