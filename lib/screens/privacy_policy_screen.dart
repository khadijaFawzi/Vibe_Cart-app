import 'package:flutter/material.dart';
import 'package:vibe_cart/utils/constants.dart';
import 'package:vibe_cart/utils/theme.dart';

 

class  PrivacyPolicyScreen extends StatelessWidget {
  const  PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سياسة الخصوصية'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'سياسة الخصوصية لتطبيق ${AppConstants.appName}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Center(
                child: Text(
                  'آخر تحديث: 15 أبريل 2025',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              _buildPolicySection(
                title: 'مقدمة',
                content: 'نرحب بك في تطبيق VibeCart. نحن نقدر ثقتك بنا ونلتزم بحماية خصوصيتك. تصف سياسة الخصوصية هذه كيفية جمع واستخدام وحماية المعلومات الشخصية التي تقدمها عند استخدام تطبيقنا.',
              ),
              
              _buildPolicySection(
                title: 'المعلومات التي نجمعها',
                content: 'نجمع أنواعًا مختلفة من المعلومات لتوفير وتحسين خدماتنا لك:\n\n'
                  '• معلومات التسجيل: عند إنشاء حساب، نجمع اسمك وبريدك الإلكتروني ورقم هاتفك وكلمة المرور.\n\n'
                  '• معلومات الملف الشخصي: أي معلومات إضافية تختار مشاركتها في ملفك الشخصي، مثل العنوان وصورة الملف الشخصي.\n\n'
                  '• معلومات المعاملات: تفاصيل المنتجات التي تشتريها والطلبات التي تقدمها وتفاصيل الدفع.\n\n'
                  '• معلومات الاستخدام: كيفية استخدامك للتطبيق، بما في ذلك الصفحات التي تزورها والمنتجات التي تستعرضها.',
              ),
              
              _buildPolicySection(
                title: 'كيفية استخدام المعلومات',
                content: 'نستخدم المعلومات التي نجمعها لعدة أغراض:\n\n'
                  '• توفير وتحسين خدماتنا: لتمكينك من استخدام التطبيق وميزاته.\n\n'
                  '• معالجة المعاملات: لمعالجة الطلبات وإتمام عمليات الشراء.\n\n'
                  '• التواصل: للرد على استفساراتك وتزويدك بالتحديثات والإشعارات.\n\n'
                  '• تحسين التجربة: لتخصيص وتحسين تجربتك في استخدام التطبيق.\n\n'
                  '• الأمان: لحماية حسابك والكشف عن الاحتيال ومنعه.',
              ),
              
              _buildPolicySection(
                title: 'مشاركة المعلومات',
                content: 'نحن لا نبيع أو نؤجر معلوماتك الشخصية لأطراف ثالثة. ومع ذلك، قد نشارك معلوماتك في الحالات التالية:\n\n'
                  '• مع المراكز التجارية: لمعالجة طلباتك وتوصيلها.\n\n'
                  '• مع مقدمي الخدمات: الذين يساعدوننا في تشغيل التطبيق وتقديم الخدمات.\n\n'
                  '• عند الالتزام القانوني: عندما نعتقد أن الكشف ضروري للامتثال للقانون أو حماية حقوقنا أو سلامة الآخرين.',
              ),
              
              _buildPolicySection(
                title: 'أمان البيانات',
                content: 'نتخذ تدابير أمنية معقولة لحماية معلوماتك الشخصية من الوصول غير المصرح به أو الكشف أو التعديل أو الإتلاف غير المشروع. ومع ذلك، لا يمكن ضمان أمان البيانات المرسلة عبر الإنترنت بنسبة 100%.',
              ),
              
              _buildPolicySection(
                title: 'حقوقك',
                content: 'لديك الحق في:\n\n'
                  '• الوصول إلى معلوماتك الشخصية التي نحتفظ بها.\n\n'
                  '• تصحيح أي معلومات غير دقيقة أو غير كاملة.\n\n'
                  '• حذف حسابك ومعلوماتك الشخصية.\n\n'
                  '• الاعتراض على معالجة معلوماتك.',
              ),
              
              _buildPolicySection(
                title: 'التغييرات على سياسة الخصوصية',
                content: 'قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سنخطرك بأي تغييرات مادية عن طريق نشر السياسة الجديدة على هذه الصفحة ومن خلال تنبيه في التطبيق.',
              ),
              
              _buildPolicySection(
                title: 'اتصل بنا',
                content: 'إذا كان لديك أي أسئلة حول سياسة الخصوصية هذه، يرجى الاتصال بنا على: privacy@vibecart.com',
              ),
              
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('موافق'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPolicySection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
