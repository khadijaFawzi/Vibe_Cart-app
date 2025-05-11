import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:vibe_cart/models/product_model.dart';
import 'package:vibe_cart/screens/product_details_screen.dart';
import 'package:vibe_cart/services/provider_manager.dart';
import 'package:vibe_cart/utils/theme.dart';

class PriceComparisonScreen extends StatefulWidget {
  final int productId;

  const PriceComparisonScreen({
    super.key,
    required this.productId,
  });

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  bool _isLoading = true;
  String _error = '';
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadPriceComparison();
  }

  Future<void> _loadPriceComparison() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final products = await context
          .read<ProductProvider>()
          .getProductPriceComparison(widget.productId);

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _products.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مقارنة الأسعار'),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              )
            : _error.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ: $_error',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPriceComparison,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : _products.isEmpty
                    ? const Center(
                        child: Text('لا توجد منتجات للمقارنة'),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  _products.first.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'أسعار المنتج في المراكز التجارية المختلفة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          if (_products.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Card(
                                color: Colors.green.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'أفضل سعر',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'مركز ${_products.first.centerId} بسعر ${_products.first.discountedPrice.toStringAsFixed(0)} ريال',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                final isLowestPrice = index == 0;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: isLowestPrice
                                        ? const BorderSide(
                                            color: Colors.green, width: 1.5)
                                        : BorderSide.none,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailsScreen(
                                                  product: product),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: SizedBox(
                                              width: 80,
                                              height: 80,
                                              child: product.imageUrl.isNotEmpty
                                                  ? Image.network(
                                                      product.imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const Icon(
                                                          Icons
                                                              .local_grocery_store,
                                                          size: 40,
                                                          color:
                                                              AppColors.accent,
                                                        );
                                                      },
                                                    )
                                                  : const Icon(
                                                      Icons.local_grocery_store,
                                                      size: 40,
                                                      color: AppColors.accent,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'مركز ${product.centerId}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                product.isOffer
                                                    ? Row(
                                                        children: [
                                                          Text(
                                                            '${product.discountedPrice.toStringAsFixed(0)} ريال',
                                                            style: TextStyle(
                                                              color: isLowestPrice
                                                                  ? Colors.green
                                                                  : AppColors
                                                                      .accent,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            '${product.price.toStringAsFixed(0)} ريال',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Text(
                                                        '${product.price.toStringAsFixed(0)} ريال',
                                                        style: TextStyle(
                                                          color: isLowestPrice
                                                              ? Colors.green
                                                              : AppColors
                                                                  .accent,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                if (index > 0)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                      'أغلى بـ ${(product.discountedPrice - _products.first.discountedPrice).toStringAsFixed(0)} ريال',
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              final cartProvider = context
                                                  .read<CartProvider>();
                                              cartProvider.addToCart(product);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'تم إضافة المنتج إلى العربة'),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );

                                              Future.delayed(
                                                const Duration(seconds: 2),
                                                () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductDetailsScreen(
                                                        product: product,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isLowestPrice
                                                  ? Colors.green
                                                  : AppColors.accent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 16,
                                              ),
                                            ),
                                            child: const Text('اختيار'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
