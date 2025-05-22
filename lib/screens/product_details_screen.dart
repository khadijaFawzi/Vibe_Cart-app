// lib/screens/product_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vibe_cart/models/product.dart';
import 'package:vibe_cart/models/price_comparison.dart';
import 'package:vibe_cart/models/cart_item.dart';
import 'package:vibe_cart/models/cart_group.dart';
import 'package:vibe_cart/provider/cart_provider.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/provider/favorites_provider.dart';
import 'package:vibe_cart/screens/checkout_screen.dart';
import 'package:vibe_cart/screens/price_comparison_screen.dart';
import 'package:vibe_cart/utils/theme.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorited = favoritesProvider.favorites
        .any((fav) => fav.productId == product.id);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المنتج'),
          actions: [
            IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : null,
              ),
              onPressed: () async {
                if (isFavorited) {
                  await favoritesProvider.removeFavorite(product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت إزالة المنتج من المفضلة')),
                  );
                } else {
                  await favoritesProvider.addFavorite(product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة المنتج إلى المفضلة')),
                  );
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              SizedBox(
                width: double.infinity,
                height: 250,
                child: product.image.isNotEmpty
                    ? Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.local_grocery_store,
                            size: 100,
                            color: AppColors.accent,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.local_grocery_store,
                          size: 100,
                          color: AppColors.accent,
                        ),
                      ),
              ),

              // معلومات المنتج
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product.price.toStringAsFixed(0)} ر.س',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                    if (product.isOffer) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'عرض خاص',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // زر المقارنة
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PriceComparisonScreen(
                                barcode: product.barcode),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.compare_arrows,
                                color: Colors.blue, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'مقارنة السعر بين المراكز',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'الوصف',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // اختيار الكمية
                    const Text(
                      'الكمية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // أزرار الشراء والإضافة للعربة
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                // استدعاء مزود المنتج
                                final prodProv = context.read<ProductProvider>();
                                final comp = await prodProv.getComparisonByBarcode(
                                    product.barcode);
                                if (comp.offers.isEmpty) {
                                  throw Exception('لا توجد عروض للطلب');
                                }
                                // اختيار أفضل سعر
                                final bestOffer = comp.offers.firstWhere(
                                  (o) => o.price == comp.minPrice,
                                  orElse: () => comp.offers.first,
                                );
                                // إضافة إلى السلة
                                await context.read<CartProvider>().add(
                                  product.id,
                                  bestOffer.supermarketId,
                                  _quantity,
                                );
                                // تحضير عناصر الطلب المؤقتة
                                final tempItem = CartItem(
                                  id: 0,
                                  productId: product.id,
                                  productName: product.productName,
                                  supermarketId: bestOffer.supermarketId,
                                  supermarketName: bestOffer.supermarketName,
                                  quantity: _quantity,
                                  price: bestOffer.price,
                                  total: bestOffer.price * _quantity,
                                  imageUrl: product.image,
                                );
                               final tempGroup = CartGroup(
  supermarketId: bestOffer.supermarketId,   // <-- أضف هذا السطر
  supermarket: bestOffer.supermarketName,
  subtotal: tempItem.total,
  items: [tempItem],
);

                                // الانتقال لصفحة الدفع
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CheckoutScreen(
                                      groups: [tempGroup],
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('فشل الطلب: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('اطلب الآن'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                final prodProv = context.read<ProductProvider>();
                                final comp = await prodProv.getComparisonByBarcode(
                                    product.barcode);
                                if (comp.offers.isEmpty) {
                                  throw Exception(
                                      'لا توجد عروض لإضافة للعربة');
                                }
                                final bestOffer = comp.offers.firstWhere(
                                  (o) => o.price == comp.minPrice,
                                  orElse: () => comp.offers.first,
                                );
                                await context.read<CartProvider>().add(
                                  product.id,
                                  bestOffer.supermarketId,
                                  _quantity,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'تم إضافة المنتج إلى العربة'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('فشل الإضافة: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('أضف للعربة'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
