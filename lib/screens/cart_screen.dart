// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/provider/cart_provider.dart';
import 'package:vibe_cart/models/cart_group.dart';
import 'package:vibe_cart/screens/checkout_screen.dart';
import 'package:vibe_cart/utils/theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final groups = cartProvider.groups;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('العربة')),
        body: groups.isEmpty
            ? const _EmptyCart()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: groups.map((grp) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        grp.supermarket,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        'الإجمالي: ${grp.subtotal.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(color: AppColors.accent),
                      ),
                      children: [
                        // قائمة العناصر
                        ...grp.items.map((item) => ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.store,
                                        color: AppColors.accent,
                                        size: 40,
                                      ),
                              ),
                              title: Text(item.productName),
                              subtitle: Text(
                                '×${item.quantity} = ${item.total.toStringAsFixed(2)} ر.س',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: item.quantity > 1
                                        ? () => cartProvider.update(
                                            item.id, item.quantity - 1)
                                        : null,
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => cartProvider.update(
                                        item.id, item.quantity + 1),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () => cartProvider.remove(item.id),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(),
                        // زر إتمام الطلب لهذا السوبرماركت
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CheckoutScreen(
                                      groups: [grp],
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'إتمام طلب هذا السوبرماركت',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'العربة فارغة',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text('أضف بعض المنتجات إلى عربة التسوق',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
