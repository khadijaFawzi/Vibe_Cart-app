import 'package:flutter/material.dart';

IconData getCategoryIcon(String name) {
  name = name.trim(); // إزالة الفراغات في البداية والنهاية
  if (name.contains('سكر')) return Icons.cake;
  if (name.contains('زيت')) return Icons.oil_barrel;
  if (name.contains('دقيق')) return Icons.bakery_dining;
  if (name.contains('حليب')) return Icons.local_drink;
  if (name.contains('ملح')) return Icons.spa;
  if (name.contains('شاي')) return Icons.emoji_food_beverage;
  if (name.contains('قهوة')) return Icons.coffee;
  if (name.contains('رز') || name.contains('أرز')) return Icons.rice_bowl;
  if (name.contains('شوكلاته') || name.contains('شكولاتة') || name.contains('شوكولاتة')) return Icons.icecream;
  if (name.contains('مكرونة') || name.contains('معكرونة')) return Icons.ramen_dining;
  if (name.contains('صلصة')) return Icons.soup_kitchen;
  if (name.contains('فول') || name.contains('فاصوليا')) return Icons.eco;
  if (name.contains('عدس')) return Icons.grass;
  if (name.contains('تونة') || name.contains('سمك')) return Icons.set_meal;
  if (name.contains('سمن') || name.contains('زبدة')) return Icons.breakfast_dining;
  if (name.contains('بيض')) return Icons.egg;
  if (name.contains('عسل')) return Icons.liquor; // أقرب أيقونة (قارورة)
  if (name.contains('ماء') || name.contains('مياه')) return Icons.water;
  if (name.contains('خل')) return Icons.local_drink;
  if (name.contains('شوربة')) return Icons.soup_kitchen;
  if (name.contains('تمر')) return Icons.park; // لا يوجد أيقونة تمر مباشرة، اخترت أيقونة طبيعية
  if (name.contains('عصير') || name.contains('عصائر')) return Icons.local_bar;
  if (name.contains('مكسرات')) return Icons.spa;
  if (name.contains('لبن')) return Icons.icecream;
  if (name.contains('زبادي')) return Icons.icecream;
  if (name.contains('كريم')) return Icons.icecream;
  if (name.contains('جبن') || name.contains('جبنة')) return Icons.lunch_dining;
  if (name.contains('خبز')) return Icons.bakery_dining;
  if (name.contains('كعك') || name.contains('كيك')) return Icons.cake;
  if (name.contains('حلويات')) return Icons.cake;
  if (name.contains('لحوم') || name.contains('لحم')) return Icons.set_meal;
  if (name.contains('دجاج') || name.contains('فراخ')) return Icons.restaurant;
  if (name.contains('سمك') || name.contains('أسماك')) return Icons.set_meal;
  if (name.contains('فواكه') || name.contains('فاكهة')) return Icons.apple;
  if (name.contains('خضار') || name.contains('خضروات')) return Icons.eco;
  if (name.contains('بطاطس')) return Icons.eco; // لا يوجد أيقونة بطاطس، eco مناسبة للخضار
  if (name.contains('بصل') || name.contains('ثوم')) return Icons.eco;
  if (name.contains('عطور') || name.contains('معطر')) return Icons.local_florist;
  if (name.contains('مربى')) return Icons.icecream;
  if (name.contains('مشروبات')) return Icons.local_bar;
  if (name.contains('بقوليات')) return Icons.grass;
  if (name.contains('توابل') || name.contains('بهارات')) return Icons.spa;
  if (name.contains('شيبس')) return Icons.local_pizza;
  if (name.contains('بسكويت') || name.contains('كوكيز')) return Icons.cookie;
  if (name.contains('معلبات')) return Icons.inventory_2;
  if (name.contains('جوز')) return Icons.spa;
  if (name.contains('لب')) return Icons.spa;
  if (name.contains('زيتون')) return Icons.park;
  if (name.contains('مخللات')) return Icons.park;
  if (name.contains('ذرة')) return Icons.eco;
  if (name.contains('صلصات')) return Icons.soup_kitchen;
  if (name.contains('شوربة')) return Icons.soup_kitchen;
  if (name.contains('صلصة')) return Icons.soup_kitchen;
  if (name.contains('عجائن')) return Icons.ramen_dining;
  if (name.contains('حلويات')) return Icons.cake;
  if (name.contains('صلصة')) return Icons.soup_kitchen;

  // افتراضي لأي فئة غير معروفة
  return Icons.category;
}
