import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:vibe_cart/utils/constants.dart';
import 'package:vibe_cart/utils/theme.dart';
 

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  String _version = '';
  
  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }
  
  Future<void> _getAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _version = '1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('عن التطبيق'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // شعار التطبيق
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'VC',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // اسم التطبيق
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                AppConstants.appSlogan,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'الإصدار: $_version',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              
              // وصف التطبيق
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نبذة عن التطبيق',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'VibeCart هو تطبيق تسوق إلكتروني يركّز على عرض المنتجات الغذائية من مراكز تجارية متعددة في حضرموت، مع إمكانية المقارنة بين الأسعار والشراء مباشرة من التطبيق.\n\n'
                        'يوفر التطبيق تجربة تسوق سلسة وسهلة للمستخدمين، مع العديد من الميزات التي تساعدهم على اختيار المنتجات بأفضل الأسعار من المراكز التجارية المختلفة.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // ميزات التطبيق
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ميزات التطبيق',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        icon: Icons.shopping_cart,
                        title: 'تسوق سهل',
                        description: 'تصفح وشراء المنتجات الغذائية بسهولة من مراكز تجارية متعددة',
                      ),
                      _buildFeatureItem(
                        icon: Icons.compare,
                        title: 'مقارنة الأسعار',
                        description: 'مقارنة أسعار المنتجات بين المراكز التجارية المختلفة',
                      ),
                      _buildFeatureItem(
                        icon: Icons.local_offer,
                        title: 'عروض وخصومات',
                        description: 'اطلع على أحدث العروض والخصومات من المراكز التجارية',
                      ),
                      _buildFeatureItem(
                        icon: Icons.favorite,
                        title: 'قائمة المفضلة',
                        description: 'احفظ منتجاتك المفضلة للوصول إليها لاحقًا',
                      ),
                      _buildFeatureItem(
                        icon: Icons.payments,
                        title: 'طرق دفع متعددة',
                        description: 'اختر من بين طرق دفع متعددة لإتمام عملية الشراء',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // فريق التطوير
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فريق التطوير',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'تم تطوير هذا التطبيق كمشروع جامعي من قبل فريق من طلاب كلية الحاسوب في جامعة حضرموت.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'للتواصل مع الفريق: team@vibecart.com',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // حقوق النشر
              const Text(
                '© 2025 VibeCart. جميع الحقوق محفوظة.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
