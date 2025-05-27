class Offer {
  final int id;
  final int supermarketId;
  final String? supermarketName;
  final int? productId;
  final String? productName;
  final String? productImage;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? discountPercentage;
  final String? description;
  final String? offerImage;
  final bool isAiProcessed;
  final String? extractedText;
  final bool isVerified;
  final double? originalPrice;      // السعر الأصلي
  final double? discountedPrice;    // السعر بعد الخصم

  Offer({
    required this.id,
    required this.supermarketId,
    this.supermarketName,
    this.productId,
    this.productName,
    this.productImage,
    this.startDate,
    this.endDate,
    this.discountPercentage,
    this.description,
    this.offerImage,
    required this.isAiProcessed,
    this.extractedText,
    required this.isVerified,
    this.originalPrice,
    this.discountedPrice,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1';
    }

    // الصورة
    String? imageName = json['Image']?.toString() ?? json['image']?.toString();
    String? productImageUrl;
    if (imageName != null && imageName.isNotEmpty) {
      productImageUrl = 'http://192.168.1.107:8000/products/$imageName';
    }

    return Offer(
      id: parseInt(json['id']),
      supermarketId: parseInt(json['supermarket_id']),
      supermarketName: json['supermarket_name']?.toString() ?? json['SupermarketName']?.toString(),
      productId: json['product_id'] != null ? parseInt(json['product_id']) : null,
      productName: json['product_name']?.toString(),
      productImage: productImageUrl,
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      discountPercentage: parseDouble(json['discount_percentage']),
      description: json['Description']?.toString() ?? json['description']?.toString(),
      offerImage: json['offer_image']?.toString() ?? json['image']?.toString(),
      isAiProcessed: parseBool(json['is_ai_processed']),
      extractedText: json['extracted_text']?.toString(),
      isVerified: parseBool(json['is_verified']),
      originalPrice: parseDouble(json['original_price']),       // السعر الأصلي من الـ API
      discountedPrice: parseDouble(json['discounted_price']),   // السعر بعد الخصم من الـ API
    );
  }
  String formatDate(DateTime? date) {
  if (date == null) return '';
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
}

}
