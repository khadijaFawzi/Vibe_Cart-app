// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:vibe_cart/screens/product_details_screen.dart';
import 'package:vibe_cart/services/provider_manager.dart';
import 'package:vibe_cart/utils/theme.dart';
 

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المفضلة'),
          actions: [
            if (favoritesProvider.favoriteCount > 0)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('مسح المفضلة'),
                      content: const Text('هل أنت متأكد من رغبتك في مسح كل العناصر من المفضلة؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () {
                            favoritesProvider.clearFavorites();
                            Navigator.of(context).pop();
                          },
                          child: const Text('مسح'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
        body: favoritesProvider.favoriteCount == 0
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'قائمة المفضلة فارغة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'أضف بعض المنتجات إلى المفضلة',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: favoritesProvider.favorites.length,
                itemBuilder: (context, index) {
                  final product = favoritesProvider.favorites[index];
                  final cartProvider = context.watch<CartProvider>();
                  final isInCart = cartProvider.isInCart(product.id);
                  
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
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: SizedBox(
                              height: 120,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
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
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        favoritesProvider.removeFromFavorites(product.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('تم إزالة المنتج من المفضلة'),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // تفاصيل المنتج
                          Padding(
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
                                const SizedBox(height: 8),
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
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
