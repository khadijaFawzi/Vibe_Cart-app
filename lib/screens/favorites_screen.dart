import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/provider/cart_provider.dart';
import 'package:vibe_cart/provider/favorites_provider.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/screens/product_details_screen.dart';
import 'package:vibe_cart/utils/theme.dart';
import 'package:vibe_cart/models/favorite_item.dart';
import 'package:vibe_cart/models/product.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
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

    final products = favProv.favorites.where((f) => f.type == 'product').toList();
    final offers   = favProv.favorites.where((f) => f.type == 'offer').toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المفضلة'),
          actions: [
            if (favProv.favorites.isNotEmpty)
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
        body: Column(
          children: [
            // القسم العلوي: المنتجات
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'المنتجات المفضلة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: products.isNotEmpty
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, idx) => _buildFavoriteCard(
                        context,
                        products[idx],
                        prodProv,
                        cartProv,
                        favProv,
                      ),
                    )
                  : const Center(child: Text('لا توجد منتجات مفضلة')),
            ),

            // القسم السفلي: العروض
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'عروض مفضلة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: offers.isNotEmpty
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: offers.length,
                      itemBuilder: (_, idx) => _buildFavoriteCard(
                        context,
                        offers[idx],
                        prodProv,
                        cartProv,
                        favProv,
                      ),
                    )
                  : const Center(child: Text('لا توجد عروض مفضلة')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    FavoriteItem item,
    ProductProvider prodProv,
    CartProvider cartProv,
    FavoritesProvider favProv,
  ) {
    final prodId = item.productId ?? 0;
    final inCart = cartProv.isInCart(prodId);

    return FutureBuilder<List<Product>>(
      future: prodProv.getProductsBySupermarket(item.supermarketId),
      builder: (context, snapshot) {
        Product? product;
        if (snapshot.hasData) {
          try {
            product = snapshot.data!.firstWhere((p) => p.id == prodId);
          } catch (_) {}
        }

        String imageUrl = '';
        if (product != null && product.image.isNotEmpty) {
          imageUrl = product.image.startsWith('http')
              ? product.image
              : 'http://192.168.1.107:8000/products/${product.image}';
        }

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: product == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(
                        product: product!, // نستخدم ! لأننا تأكدنا أنه ليس null
                      ),
                            ),
                          );
                        },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: (product != null && imageUrl.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.network(
                              imageUrl,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, size: 40, color: AppColors.accent),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.image, size: 40, color: AppColors.accent),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   product?.productName ?? item.productName,
                    //   style: const TextStyle(fontWeight: FontWeight.bold),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    const SizedBox(height: 4),
                    Text(
                      'متوفر في: ${product?.supermarketName ?? item.supermarketName}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product != null) ...[
                      Text(
                        '${product.price.toStringAsFixed(2)} ر.ي',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () async {
                            await favProv.removeFavorite(
                              type: item.type,
                              favoritableId: item.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تمت إزالة من المفضلة')),
                            );
                          },
                        ),
                        ElevatedButton(
                          onPressed: inCart || product == null
                              ? null
                              : () async {
                                  await cartProv.add(prodId, item.supermarketId, 1);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تمت إضافة إلى العربة'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                          child: Text(inCart ? 'في العربة' : 'أضف للعربة'),
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
    );
  }
}
