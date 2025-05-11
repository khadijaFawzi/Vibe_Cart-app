 
class ShoppingCenter {
  final int id;
  final String name;
  final String logoUrl;
  final String? description;
  final String? address;
  final String? phoneNumber;

  ShoppingCenter({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.description,
    this.address,
    this.phoneNumber,
  });

  factory ShoppingCenter.fromJson(Map<String, dynamic> json) {
    return ShoppingCenter(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'],
      description: json['description'],
      address: json['address'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'description': description,
      'address': address,
      'phone_number': phoneNumber,
    };
  }
}
