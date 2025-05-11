class AppConstants {
  // عام
  static const String appName = 'VibeCart';
  static const String appSlogan = 'الاختيار الأنسب لك';

  // رسائل
  static const String networkError = 'تأكد من اتصالك بالإنترنت';
  static const String serverError = 'حدث خطأ في الخادم، حاول مرة أخرى';
  static const String unknownError = 'حدث خطأ غير متوقع، حاول مرة أخرى';

  // بيانات التحويل البنكي
  static const Map<String, String> bankAccounts = {
    'العمقي': '12469976432',
    'البسيري': '22357891757',
    'الكريمي': '1467997678',
  };

  // قائمة الفئات
  static const List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'الأرز', 'icon': 'rice'},
    {'id': 2, 'name': 'الزيت', 'icon': 'oil'},
    {'id': 3, 'name': 'السكر', 'icon': 'sugar'},
    {'id': 4, 'name': 'العصائر', 'icon': 'juice'},
    {'id': 5, 'name': 'التونة', 'icon': 'tuna'},
    {'id': 6, 'name': 'الشبسات', 'icon': 'chips'},
  ];

  // قائمة المراكز التجارية
  static const List<Map<String, dynamic>> centers = [
    {'id': 1, 'name': 'الشحر مول', 'logo': 'shahr_mall'},
    {'id': 2, 'name': 'باسعد', 'logo': 'basaad'},
    {'id': 3, 'name': 'تبارك', 'logo': 'tabarak'},
    {'id': 4, 'name': 'العمقي', 'logo': 'amqi'},
  ];

  // معلومات التواصل
  static const String supportEmail = 'support@vibecart.com';
  static const String supportPhone = '+967 123456789';
  static const String teamEmail = 'team@vibecart.com';

  // روابط
  static const String privacyPolicyUrl = 'https://vibecart.com/privacy';
  static const String termsUrl = 'https://vibecart.com/terms';
  static const String faqUrl = 'https://vibecart.com/faq';
}
