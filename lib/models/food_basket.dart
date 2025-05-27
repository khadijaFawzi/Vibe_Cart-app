import 'supermarket.dart'; // إذا لديك كلاس سوبرماركت في ملف منفصل

class FoodBasket {
  final int id;
  final String name;
  final String? image;
  final String? description;
  final double price;
  final String startDate;
  final String endDate;
  final SuperMarket? supermarket; // أضف هذا الحقل

  FoodBasket({
    required this.id,
    required this.name,
    this.image,
    this.description,
    required this.price,
    required this.startDate,
    required this.endDate,
    this.supermarket,
  });

  factory FoodBasket.fromJson(Map<String, dynamic> json) {
    return FoodBasket(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'],
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      supermarket: json['supermarket'] != null
          ? SuperMarket.fromJson(json['supermarket'])
          : null,
    );
  }
}
