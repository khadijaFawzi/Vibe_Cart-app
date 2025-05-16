class SuperMarket {
  final int id;
  final String supermarketName;
  final String location;
  final String contactNumber;
  final String? description;    // nullable
  final String? bankAccount;    // nullable
  final String profileImage;
  final dynamic user;           // أو عرّفه حسب نوعه إذا تعرفه

  SuperMarket({
    required this.id,
    required this.supermarketName,
    required this.location,
    required this.contactNumber,
    this.description,
    this.bankAccount,
    required this.profileImage,
    this.user,
  });

  /// يبني رابط الصورة الكامل استنادًا إلى اسم الملف
    String get imageUrl =>
      'http://192.168.1.107:8000/uploads/$profileImage';

  factory SuperMarket.fromJson(Map<String, dynamic> json) {
    return SuperMarket(
      id: json['id'] as int,
      supermarketName: (json['SupermarketName'] as String?) ?? '',
      location: (json['Location'] as String?) ?? '',
      contactNumber: json['ContactNumber']?.toString() ?? '',
      description: json['description'] as String?,
      bankAccount: json['bank_account'] as String?,
      profileImage: (json['profile_image'] as String?) ?? '',
      user: json['user'],
    );
  }
}
