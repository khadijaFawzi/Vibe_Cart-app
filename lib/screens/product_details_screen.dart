// lib/screens/product_details_screen.dart
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:vibe_cart/models/product_model.dart';
import 'package:vibe_cart/screens/checkout_screen.dart';
import 'package:vibe_cart/screens/price_comparison_screen.dart';
import 'package:vibe_cart/services/provider_manager.dart';
import 'package:vibe_cart/utils/theme.dart';
 

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  
  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  
  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final cartProvider = context.watch<CartProvider>();
    
    final isInFavorites = favoritesProvider.isInFavorites(widget.product.id);
    final isInCart = cartProvider.isInCart(widget.product.id);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المنتج'),
          actions: [
            IconButton(
              icon: Icon(
                isInFavorites ? Icons.favorite : Icons.favorite_border,
                color: isInFavorites ? Colors.red : null,
              ),
              onPressed: () {
                if (isInFavorites) {
                  favoritesProvider.removeFromFavorites(widget.product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إزالة المنتج من المفضلة')),
                  );
                } else {
                  favoritesProvider.addToFavorites(widget.product);
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
                child: widget.product.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.local_grocery_store,
                              size: 100,
                              color: AppColors.accent,
                            ),
                          );
                        },
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
                    // اسم المنتج
                    
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // السعر
                    if (widget.product.isOffer)
                      Row(
                        children: [
                          Text(
                            '${widget.product.discountedPrice.toStringAsFixed(0)} ريال',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.product.price.toStringAsFixed(0)} ريال',
                            style: const TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'خصم ${widget.product.discountPercentage?.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${widget.product.price.toStringAsFixed(0)} ريال',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    // المركز التجاري
                    Row(
                      children: [
                        const Icon(Icons.store, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text(
                          'المركز التجاري:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'مركز ${widget.product.centerId}', // سيتم تحديثه لاستخدام اسم المركز الفعلي
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // زر المقارنة
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PriceComparisonScreen(productId: widget.product.id),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.compare_arrows, color: Colors.blue, size: 18),
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
                    
                    // وصف المنتج
                    const Text(
                      'الوصف',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description,
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
                              ? () {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // أزرار الشراء والإضافة للعربة
                    Row(
                      children: [
                        // زر الطلب الآن
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              cartProvider.addToCart(widget.product, quantity: _quantity);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CheckoutScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('اطلب الآن'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // زر الإضافة للعربة
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: isInCart
                                ? null
                                : () {
                                    cartProvider.addToCart(widget.product, quantity: _quantity);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم إضافة المنتج إلى العربة')),
                                    );
                                  },
                            icon: const Icon(Icons.shopping_cart),
                            label: Text(isInCart ? 'في العربة' : 'أضف للعربة'),
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
