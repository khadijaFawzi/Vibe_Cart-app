import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/utils/theme.dart';

import '../provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userData;

    _nameController = TextEditingController(text: user?['username']);
    _emailController = TextEditingController(text: user?['email']);
    _phoneController = TextEditingController(text: user?['phone_number']);
    _addressController = TextEditingController(text: user?['address'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // هنا ممكن تنفذ عملية تحديث في الباك اند لو حبيت، حسب تصميمك
      // حالياً فقط نعرض رسالة
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات محليًا')),
        );
        setState(() {
          _isEditing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userData;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('لم يتم تسجيل الدخول'),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    _nameController.text = user['username'];
                    _emailController.text = user['email'];
                    _phoneController.text = user['phone_number'];
                    _addressController.text = user['address'] ?? '';
                  }
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.secondary,
                      child: Text(
                        user['username'][0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildProfileField(
                  label: 'الاسم الكامل',
                  controller: _nameController,
                  icon: Icons.person,
                  readOnly: !_isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم الكامل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  label: 'البريد الإلكتروني',
                  controller: _emailController,
                  icon: Icons.email,
                  readOnly: true, // غالبًا البريد ما يتعدل
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  label: 'رقم الهاتف',
                  controller: _phoneController,
                  icon: Icons.phone,
                  readOnly: !_isEditing,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  label: 'العنوان',
                  controller: _addressController,
                  icon: Icons.location_on,
                  readOnly: !_isEditing,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text(
                      'حفظ التغييرات',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
      ),
      validator: validator,
);
}
}
