
// lib/models/product_model.dart
class PriceComparisons {
  final int id;
  final String productName;
  final String barcode;             // لإضافة حقل الباركود
  final double price;
  final int categoryId;
  final String description;
  final String image;
  final int supermarketId;
  
  final bool isOffer;               // اختياري لتحديد ما إذا كان المنتج عرضًا

  PriceComparisons({
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

  factory PriceComparisons.fromJson(Map<String, dynamic> json) {
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
    final categoryId = (json['category_id'] as num?)?.toInt() ?? 0;
    final description = (json['Description'] as String?)
            ?? (json['description'] as String?)
            ?? '';
    final image = (json['Image'] as String?)
            ?? (json['image_url'] as String?)
            ?? '';
    final supermarketId = (json['supermarket_id'] as num?)?.toInt() ?? 0;
    final isOffer = json['is_offer'] == 1 || json['is_offer'] == true;

    return PriceComparisons(
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
