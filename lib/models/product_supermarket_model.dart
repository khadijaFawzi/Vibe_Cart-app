 
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int centerId;
  final int categoryId;
  final bool isOffer;
  final double? discountPercentage;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.centerId,
    required this.categoryId,
    this.isOffer = false,
    this.discountPercentage,
  });

  double get discountedPrice {
    if (isOffer && discountPercentage != null) {
      return price - (price * discountPercentage! / 100);
    }
    return price;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
      centerId: json['center_id'],
      categoryId: json['category_id'],
      isOffer: json['is_offer'] ?? false,
      discountPercentage: json['discount_percentage'] != null
          ? double.parse(json['discount_percentage'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'center_id': centerId,
      'category_id': categoryId,
      'is_offer': isOffer,
      'discount_percentage': discountPercentage,
    };
  }}