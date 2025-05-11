// lib/screens/help_center_screen.dart
import 'package:flutter/material.dart';
import 'package:vibe_cart/screens/contact_us_screen.dart';
import 'package:vibe_cart/utils/theme.dart';

 

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<Map<String, dynamic>> _faqList = [
    {
      'question': 'كيف يمكنني إنشاء حساب في التطبيق؟',
      'answer': 'يمكنك إنشاء حساب في التطبيق عن طريق النقر على "إنشاء حساب" في شاشة تسجيل الدخول، ثم إدخال المعلومات المطلوبة مثل الاسم والبريد الإلكتروني ورقم الهاتف وكلمة المرور.',
      'isExpanded': false,
    },
    {
      'question': 'كيف يمكنني تغيير إعدادات اللغة؟',
      'answer': 'يمكنك تغيير لغة التطبيق من خلال الذهاب إلى "الإعدادات" ثم اختيار "اللغة"، ومن ثم اختيار اللغة المطلوبة.',
      'isExpanded': false,
    },
    {
      'question': 'كيف يمكنني مقارنة أسعار المنتجات؟',
      'answer': 'يمكنك مقارنة أسعار المنتجات عن طريق النقر على زر "مقارنة الأسعار" الموجود في صفحة تفاصيل المنتج. سيعرض لك التطبيق أسعار المنتج في المراكز التجارية المختلفة.',
      'isExpanded': false,
    },
    {
      'question': 'كيف يمكنني إتمام عملية الشراء؟',
      'answer': 'لإتمام عملية الشراء، قم بإضافة المنتجات المطلوبة إلى العربة، ثم انتقل إلى العربة واضغط على "إتمام الطلب". سيطلب منك التطبيق إدخال بيانات التوصيل واختيار طريقة الدفع، ثم تأكيد الطلب.',
      'isExpanded': false,
    },
    {
      'question': 'ما هي طرق الدفع المتاحة؟',
      'answer': 'تتوفر عدة طرق للدفع في التطبيق: التحويل البنكي والدفع عند الاستلام. في حالة التحويل البنكي، ستظهر لك بيانات التحويل البنكي للمركز التجاري المختار وستتمكن من رفع إيصال التحويل عبر التطبيق.',
      'isExpanded': false,
    },
    {
      'question': 'كيف يمكنني الاطلاع على العروض؟',
      'answer': 'يمكنك الاطلاع على العروض اليومية في الصفحة الرئيسية للتطبيق. كما يُظهر التطبيق علامة "خصم" على المنتجات المعروضة.',
      'isExpanded': false,
    },
    {
      'question': 'كيف يمكنني إضافة منتج إلى المفضلة؟',
      'answer': 'يمكنك إضافة منتج إلى المفضلة عن طريق الضغط على أيقونة القلب الموجودة في بطاقة المنتج أو في صفحة تفاصيل المنتج.',
      'isExpanded': false,
    },
    {
      'question': 'هل يمكنني تغيير العنوان بعد تأكيد الطلب؟',
      'answer': 'لا يمكن تغيير العنوان بعد تأكيد الطلب. يرجى التأكد من إدخال العنوان الصحيح قبل تأكيد الطلب.',
      'isExpanded': false,
    },
    {
      'question': 'كيف يمكنني الاتصال بخدمة العملاء؟',
      'answer': 'يمكنك الاتصال بخدمة العملاء من خلال قسم "تواصل معنا" في الإعدادات، أو عبر البريد الإلكتروني: support@vibecart.com أو الاتصال على الرقم: +967 123456789',
      'isExpanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مركز المساعدة'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة مركز المساعدة
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      size: 60,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // نص ترحيبي
                const Text(
                  'مرحبًا بك في مركز المساعدة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'اعثر على إجابات لأسئلتك الشائعة، أو تواصل معنا للحصول على المساعدة',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // قسم الأسئلة الشائعة
                const Text(
                  'الأسئلة الشائعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // قائمة الأسئلة
                ...List.generate(
                  _faqList.length,
                  (index) => _buildFaqItem(index),
                ),
                
                const SizedBox(height: 32),
                
                // قسم لم تجد إجابة لسؤالك؟
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'لم تجد إجابة لسؤالك؟',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'يمكنك التواصل معنا مباشرة وسنقوم بالرد عليك في أقرب وقت ممكن.',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContactUsScreen(),
                            ),
                          );
                        },
                        child: const Text('تواصل معنا'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFaqItem(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          _faqList[index]['question'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onExpansionChanged: (expanded) {
          setState(() {
            _faqList[index]['isExpanded'] = expanded;
          });
        },
        trailing: Icon(
          _faqList[index]['isExpanded'] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: AppColors.accent,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _faqList[index]['answer'],
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
