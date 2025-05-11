import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibe_cart/provider/auth_provider.dart';

import 'package:vibe_cart/screens/about_app_screen.dart';
import 'package:vibe_cart/screens/contact_us_screen.dart';
import 'package:vibe_cart/screens/help_center_screen.dart';
import 'package:vibe_cart/screens/language_screen.dart';
import 'package:vibe_cart/screens/login_screen.dart';
import 'package:vibe_cart/screens/privacy_policy_screen.dart';
import 'package:vibe_cart/screens/profile_screen.dart';
import 'package:vibe_cart/screens/theme_screen.dart';
import 'package:vibe_cart/services/theme_provider.dart';
import 'package:vibe_cart/utils/constants.dart';
import 'package:vibe_cart/utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('الحساب'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.person,
                    title: authProvider.isAuthenticated ? 'الملف الشخصي' : 'تسجيل الدخول',
                    subtitle: authProvider.isAuthenticated
                        ? 'عرض وتعديل بيانات حسابك الشخصي'
                        : 'قم بتسجيل الدخول أو إنشاء حساب جديد',
                    onTap: () {
                      if (authProvider.isAuthenticated) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('المظهر'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    title: 'المظهر',
                    subtitle: themeProvider.isDarkMode ? 'الوضع الداكن مفعل' : 'الوضع الفاتح مفعل',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeScreen(),
                        ),
                      );
                    },
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    icon: Icons.language,
                    title: 'اللغة',
                    subtitle: 'تغيير لغة التطبيق',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageScreen(),
                        ),
                      );
                    },
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('الإشعارات'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Column(
                children: [
                  _buildSwitchSettingsItem(
                    icon: Icons.notifications,
                    title: 'تفعيل الإشعارات',
                    subtitle: 'تلقي إشعارات عن العروض والتحديثات',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('الدعم والمساعدة'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.help_outline,
                    title: 'مركز المساعدة',
                    subtitle: 'الأسئلة الشائعة وكيفية استخدام التطبيق',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpCenterScreen(),
                        ),
                      );
                    },
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    icon: Icons.email_outlined,
                    title: 'تواصل معنا',
                    subtitle: 'لديك استفسار؟ راسلنا',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsScreen(),
                        ),
                      );
                    },
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('حول التطبيق'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.info_outline,
                    title: 'عن التطبيق',
                    subtitle: 'معلومات حول تطبيق ${AppConstants.appName}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutAppScreen(),
                        ),
                      );
                    },
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'سياسة الخصوصية',
                    subtitle: 'قراءة سياسة الخصوصية الخاصة بالتطبيق',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
            if (authProvider.isAuthenticated)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 32),
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تسجيل الخروج'),
                        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () {
                              authProvider.logout();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
                              );
                            },
                            child: const Text('تسجيل الخروج'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
