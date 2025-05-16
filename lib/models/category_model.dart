 
// class Category {
//   final int id;
//   final String name;
//   final String icon;

//   Category({
//     required this.id,
//     required this.name,
//     required this.icon,
//   });

//   factory Category.fromJson(Map<String, dynamic> json) {
//     return Category(
//       id: json['id'],
//       name: json['name'],
//       icon: json['icon'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'icon': icon,
//     };
//   }
// }
class Category {
  final int id;
  final String categoryName;
  final String? icon; // مسار أو اسم أيقونة الفئة

  Category({
    required this.id,
    required this.categoryName,
    this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      categoryName: (json['CategoryName'] as String?) ?? '',
      icon: (json['icon'] as String?),  // يقبل null إذا لم يُرسل السيرفر قيمة
    );
  }
}

