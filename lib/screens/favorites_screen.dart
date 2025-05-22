// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vibe_cart/models/favorite_item.dart';
import 'package:vibe_cart/models/cart_item.dart';
import 'package:vibe_cart/models/cart_group.dart';
import 'package:vibe_cart/provider/cart_provider.dart';
import 'package:vibe_cart/provider/favorites_provider.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/screens/product_details_screen.dart';
import 'package:vibe_cart/screens/checkout_screen.dart';
import 'package:vibe_cart/utils/theme.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل المفضلة عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavoritesProvider>();
    final cartProv = context.watch<CartProvider>();
    final prodProv = context.read<ProductProvider>();

    if (favProv.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (favProv.error.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text('حدث خطأ: ${favProv.error}')),
      );
    }

    final favorites = favProv.favorites;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المفضلة'),
          actions: [
            if (favorites.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () async {
                  await favProv.clearFavorites();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم مسح المفضلة')),
                  );
                },
              ),
          ],
        ),
        body: favorites.isEmpty
            ? const _EmptyFavorites()
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: favorites.length,
                itemBuilder: (_, idx) {
                  final item = favorites[idx];
                  final inCart = cartProv.isInCart(item.productId);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              // جلب قائمة المنتجات للمركز نفسه
                              final products = await prodProv
                                  .getProductsBySupermarket(item.supermarketId);
                              // البحث عن المنتج المطابق
                              final product = products.firstWhere(
                                (p) => p.id == item.productId,
                                orElse: () => throw Exception(
                                    'المنتج غير موجود في هذا المركز'),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailsScreen(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.local_grocery_store,
                                size: 40,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'متوفر في: ${item.supermarketName}',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await favProv
                                          .removeFavorite(item.productId);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'تمت إزالة من المفضلة'),
                                        ),
                                      );
                                    },
                                  ),
                                  ElevatedButton(
                                    onPressed: inCart
                                        ? null
                                        : () async {
                                            await cartProv.add(
                                              item.productId,
                                              item.supermarketId,
                                              1,
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'تمت إضافة إلى العربة'),
                                                backgroundColor:
                                                    Colors.green,
                                              ),
                                            );
                                          },
                                    child: Text(
                                        inCart ? 'في العربة' : 'أضف للعربة'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'لا توجد عناصر في المفضلة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
}
