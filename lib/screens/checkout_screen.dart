import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:vibe_cart/models/cart_group.dart';
import 'package:vibe_cart/provider/OrderProvider.dart';
import 'package:vibe_cart/provider/cart_provider.dart';

import 'package:vibe_cart/models/bank_account.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartGroup> groups;

  const CheckoutScreen({Key? key, required this.groups}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0;
  final List<String> _paymentMethods = ['تحويل بنكي', 'الدفع عند الاستلام'];

  BankAccount? _selectedBank;
  List<BankAccount> _bankAccounts = [];
  bool _banksLoading = false;
  String? _receiptImagePath;

  // بيانات العنوان (ممكن تطويرها لاحقًا)
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBankAccounts();
  }

  void _fetchBankAccounts() async {
    setState(() => _banksLoading = true);
    final supermarketId = widget.groups.first.supermarketId;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    _bankAccounts = await orderProvider.apiService.getSupermarketBankAccounts(supermarketId);
    setState(() => _banksLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups;
    final total = groups.fold<double>(0, (sum, g) => sum + g.subtotal);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إتمام الطلب')),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummary(groups, total),
                const SizedBox(height: 24),
                _buildPaymentMethods(),
                if (_selectedPaymentMethod == 0) ...[
                  const SizedBox(height: 16),
                  _buildBankSelection(),
                  if (_selectedBank != null) _buildReceiptUpload(),
                ],
                const SizedBox(height: 24),
                _buildDeliveryAddress(),
                const SizedBox(height: 24),
                _buildOrderButton(total, orderProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary(List<CartGroup> groups, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ملخص الطلب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...groups.map((grp) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(grp.supermarket, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...grp.items.map((item) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${item.quantity} × ${item.productName}'),
                Text('${item.total.toStringAsFixed(2)} ر.س'),
              ],
            )),
            const Divider(),
          ],
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('المجموع الكلي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${total.toStringAsFixed(2)} ر.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('اختر طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ..._paymentMethods.asMap().entries.map((entry) => RadioListTile<int>(
          value: entry.key,
          groupValue: _selectedPaymentMethod,
          title: Text(entry.value),
          onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
        )),
      ],
    );
  }

  Widget _buildBankSelection() {
    if (_banksLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_bankAccounts.isEmpty) {
      return const Text('لا توجد حسابات بنكية لهذا السوبرماركت.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('اختر الحساب البنكي', style: TextStyle(fontWeight: FontWeight.bold)),
        ..._bankAccounts.map((bank) => RadioListTile<BankAccount>(
          value: bank,
          groupValue: _selectedBank,
          title: Text(bank.bankName),
          subtitle: Text('رقم الحساب: ${bank.accountNumber}'),
          onChanged: (val) => setState(() => _selectedBank = val),
        )),
      ],
    );
  }

  Widget _buildReceiptUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('رفع سند التحويل:', style: TextStyle(fontWeight: FontWeight.bold)),
        InkWell(
          onTap: _pickReceiptImage,
          child: Container(
            height: 80,
            margin: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }

  Widget _buildDeliveryAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('عنوان التوصيل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'المدينة')),
        const SizedBox(height: 8),
        TextFormField(controller: _streetController, decoration: const InputDecoration(labelText: 'الشارع')),
        const SizedBox(height: 8),
        TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
        const SizedBox(height: 8),
        TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'ملاحظات إضافية'), maxLines: 2),
      ],
    );
  }

  Widget _buildOrderButton(double total, OrderProvider orderProvider) {
    return ElevatedButton(
      onPressed: orderProvider.isLoading
          ? null
          : () async {
              final supermarketId = widget.groups.first.supermarketId;
              final deliveryFee = 0.0; // أضف قيمة التوصيل حسب النظام عندك
              final products = widget.groups.first.items.map((item) => {
  'product_id': item.productId,
  'quantity': item.quantity,
  'price': item.price, // ← الحل هنا
}).toList();


              // تحقق من صحة البيانات
              if (_selectedPaymentMethod == 0 && (_selectedBank == null || _receiptImagePath == null)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر الحساب البنكي وارفع سند التحويل')));
                return;
              }
              if (_cityController.text.isEmpty || _streetController.text.isEmpty || _phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال عنوان التوصيل ورقم الهاتف')));
                return;
              }

              // أرسل الطلب
              final orderId = await orderProvider.createOrder(
                supermarketId: supermarketId,
                total: total,
                deliveryFee: deliveryFee,
                products: products,
              );

              if (orderId == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء تنفيذ الطلب')));
                return;
              }

              // في حالة الدفع البنكي: ارفع سند التحويل
              if (_selectedPaymentMethod == 0 && _receiptImagePath != null) {
                final uploaded = await orderProvider.uploadDeposit(orderId, _receiptImagePath!);
                if (!uploaded) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل رفع سند التحويل!')));
                  return;
                }
              }

              // امسح السلة واظهر رسالة نجاح
              Provider.of<CartProvider>(context, listen: false).clearCart(supermarketId);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('تم تنفيذ الطلب'),
                  content: const Text('تم تنفيذ طلبك بنجاح!'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                        child: const Text('حسنًا')),
                  ],
                ),
              );
            },
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
      child: orderProvider.isLoading
          ? const CircularProgressIndicator()
          : const Text('تأكيد الطلب', style: TextStyle(fontSize: 18)),
    );
  }

  Future<void> _pickReceiptImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _receiptImagePath = pickedFile.path);
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _streetController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
