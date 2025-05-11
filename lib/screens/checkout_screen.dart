// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:vibe_cart/services/provider_manager.dart';
import 'package:vibe_cart/utils/constants.dart';
import 'package:vibe_cart/utils/theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0;
  final List<String> _paymentMethods = ['تحويل بنكي', 'الدفع عند الاستلام'];

  bool _isConfirmed = false;
  String? _selectedCenter;
  String? _receiptImagePath;

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    if (cartProvider.cartItems.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('العربة فارغة')),
        );
        Navigator.pop(context);
      });
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إتمام الطلب'),
        ),
        body: _isConfirmed ? _buildPaymentConfirmation() : _buildCheckoutForm(cartProvider),
      ),
    );
  }

  Widget _buildCheckoutForm(CartProvider cartProvider) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('ملخص الطلب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildCartSummary(cartProvider),
              const SizedBox(height: 24),
              _buildPaymentMethods(),
              const SizedBox(height: 24),
              _buildDeliveryAddress(),
              const SizedBox(height: 24),
            ],
          ),
        ),
        _buildBottomBar(cartProvider),
      ],
    );
  }

  Widget _buildCartSummary(CartProvider cartProvider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('المنتجات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...cartProvider.cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(item.product.name)),
                  Expanded(flex: 1, child: Text('${item.quantity} x', textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('${item.product.discountedPrice.toStringAsFixed(0)} ريال')),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المجموع', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${cartProvider.totalPrice.toStringAsFixed(0)} ريال',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: List.generate(
              _paymentMethods.length,
              (index) => RadioListTile<int>(
                title: Text(_paymentMethods[index]),
                value: index,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                activeColor: AppColors.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('عنوان التوصيل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _AddressField(label: 'المدينة'),
                SizedBox(height: 16),
                _AddressField(label: 'الشارع'),
                SizedBox(height: 16),
                _AddressField(label: 'رقم الهاتف', keyboardType: TextInputType.phone),
                SizedBox(height: 16),
                _AddressField(label: 'ملاحظات إضافية', maxLines: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المجموع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '${cartProvider.totalPrice.toStringAsFixed(0)} ريال',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _isConfirmed = true),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('تأكيد الطلب', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentConfirmation() {
    final banks = AppConstants.bankAccounts.keys.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 64),
        const SizedBox(height: 16),
        const Text('تم تأكيد طلبك بنجاح', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('يرجى إكمال عملية الدفع لتأكيد الطلب نهائياً', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        const Text('بيانات التحويل البنكي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('اختر المركز التجاري للتحويل:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  value: _selectedCenter,
                  hint: const Text('اختر المركز'),
                  items: banks.map((bank) => DropdownMenuItem(value: bank, child: Text(bank))).toList(),
                  onChanged: (value) => setState(() => _selectedCenter = value),
                ),
                const SizedBox(height: 16),
                if (_selectedCenter != null) ...[
                  const Text('رقم الحساب:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppConstants.bankAccounts[_selectedCenter]!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ رقم الحساب')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text('رفع سند التحويل:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => setState(() => _receiptImagePath = 'تم اختيار صورة'),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: _receiptImagePath == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, size: 32, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('اضغط لرفع سند التحويل'),
                              ],
                            )
                          : const Text('تم اختيار صورة', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _selectedCenter != null && _receiptImagePath != null ? _completeOrder : null,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.green),
          child: const Text('تأكيد التحويل وإتمام الطلب', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: _cancelOrderDialog,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          child: const Text('إلغاء الطلب', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  void _completeOrder() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // إغلاق مؤشر التحميل
        cartProvider.clearCart(); // مسح العربة
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تم تأكيد الطلب'),
            content: const Text('تم تأكيد طلبك بنجاح! سيتم التواصل معك قريبًا.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('حسنًا'),
              ),
            ],
          ),
        );
      }
    });
  }

  void _cancelOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من رغبتك في إلغاء الطلب؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('لا')),
          TextButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: const Text('نعم، إلغاء الطلب')),
        ],
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;

  const _AddressField({required this.label, this.maxLines = 1, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }
}
