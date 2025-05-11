// lib/screens/category_screen.dart
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:vibe_cart/models/category_model.dart';
import 'package:vibe_cart/models/product_model.dart';
import 'package:vibe_cart/screens/price_comparison_screen.dart';
import 'package:vibe_cart/screens/product_details_screen.dart';
import 'package:vibe_cart/services/provider_manager.dart';
import 'package:vibe_cart/utils/theme.dart';
 

class CategoryScreen extends StatefulWidget {
  final Category category;
  
  const CategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isLoading = true;
  String _error = '';
  List<Product> _products = [];
  
  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }
  
  Future<void> _loadCategoryProducts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      final products = await context
          .read<ProductProvider>()
          .getCategoryProducts(widget.category.id);
      
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.category.name),
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
                          onPressed: _loadCategoryProducts,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : _products.isEmpty
                    ? const Center(
                        child: Text('لا توجد منتجات في هذه الفئة'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCategoryProducts,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return _buildProductItem(context, product);
                          },
                        ),
                      ),
      ),
    );
  }
  
  Widget _buildProductItem(BuildContext context, Product product) {
    final cartProvider = context.watch<CartProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    
    final isInCart = cartProvider.isInCart(product.id);
    final isInFavorites = favoritesProvider.isInFavorites(product.id);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.local_grocery_store,
                                  size: 40,
                                  color: AppColors.accent,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.local_grocery_store,
                              size: 40,
                              color: AppColors.accent,
                            ),
                          ),
                  ),
                ),
                if (product.isOffer)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'خصم ${product.discountPercentage?.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (isInFavorites) {
                        favoritesProvider.removeFromFavorites(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إزالة المنتج من المفضلة')),
                        );
                      } else {
                        favoritesProvider.addToFavorites(product);
                        // lib/screens/category_screen.dart (تكملة)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إضافة المنتج إلى المفضلة')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInFavorites ? Icons.favorite : Icons.favorite_border,
                        color: isInFavorites ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // تفاصيل المنتج
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    product.isOffer
                        ? Row(
                            children: [
                              Text(
                                '${product.discountedPrice.toStringAsFixed(0)} ريال',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.price.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '${product.price.toStringAsFixed(0)} ريال',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PriceComparisonScreen(productId: product.id),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.compare_arrows, color: Colors.blue, size: 14),
                          SizedBox(width: 2),
                          Text(
                            'مقارنة الأسعار',
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isInCart
                            ? null
                            : () {
                                cartProvider.addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم إضافة المنتج إلى العربة'),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: Text(isInCart ? 'في العربة' : 'أضف للعربة'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
