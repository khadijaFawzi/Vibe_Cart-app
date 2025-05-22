import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/provider/OrderProvider.dart';
import 'package:vibe_cart/utils/theme.dart';

import '../provider/auth_provider.dart';

import '../models/order.dart'; // أضف هذا

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

  // جلب الطلبات عند الدخول للصفحة
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<OrderProvider>(context, listen: false).fetchOrders();
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

      // هنا ممكن تنفذ عملية تحديث في الباك اند لو حبيت
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

  String _translateOrderStatus(String status) {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'processing': return 'قيد التنفيذ';
      case 'completed': return 'تم التسليم';
      case 'canceled': return 'ملغى';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userData;
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

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
                  readOnly: true,
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
                // ------------- إضافة الطلبات تحت بيانات المستخدم -------------
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "طلباتي",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: AppColors.secondary.withOpacity(0.1),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_cart_checkout, color: AppColors.primary),
                    title: Text(
                      'عدد الطلبات: ${orders.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // قائمة الطلبات
                ...orders.map((order) => Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long, color: AppColors.secondary),
                    title: Text('طلب رقم #${order.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الحالة: ${_translateOrderStatus(order.status)}'),
                        Text('الإجمالي: ${order.total.toStringAsFixed(2)} ر.س'),
                        Text('تاريخ الطلب: ${order.createdAt ?? ''}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // تقدر تفتح صفحة تفاصيل الطلب إذا أضفتها
                    },
                  ),
                )),
                if (orders.isEmpty && !orderProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('لا توجد طلبات حتى الآن')),
                  ),
                if (orderProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                // -----------------------------------------------------------
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
