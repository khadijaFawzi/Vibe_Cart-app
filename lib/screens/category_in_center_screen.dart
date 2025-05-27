import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/models/category_model.dart';
import 'package:vibe_cart/models/product.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/provider/cart_provider.dart';
import 'package:vibe_cart/provider/favorites_provider.dart';
import 'package:vibe_cart/widgets/supermarket_product_card.dart';
import 'package:vibe_cart/screens/product_details_screen.dart';

class SupermarketCategoryProductsScreen extends StatefulWidget {
  final int supermarketId;
  final Category category;

  const SupermarketCategoryProductsScreen({
    Key? key,
    required this.supermarketId,
    required this.category,
  }) : super(key: key);

  @override
  State<SupermarketCategoryProductsScreen> createState() =>
      _SupermarketCategoryProductsScreenState();
}

class _SupermarketCategoryProductsScreenState
    extends State<SupermarketCategoryProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final prodProv = context.read<ProductProvider>();
      final products = await prodProv.getProductsBySupermarketAndCategory(
        widget.supermarketId,
        widget.category.id,
      );

      setState(() {
        _products = products;
        if (products.isEmpty) {
          _error = 'لا توجد منتجات في هذه الفئة.';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ أثناء جلب المنتجات: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavoritesProvider>();
    final cartProv = context.watch<CartProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          elevation: 1.5,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Color(0xFF234D59)),
          title: Text(
            'منتجات فئة "${widget.category.categoryName}"',
            style: const TextStyle(
              color: Color(0xFF234D59),
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
                ? Center(
                    child: Text(
                      _error,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: _products.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                "لا توجد منتجات في هذه الفئة.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.73,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _products.length,
                            itemBuilder: (ctx, i) {
                              final product = _products[i];
                              final isFav = favProv.favorites.any(
                                  (f) => f.type == 'product' && f.productId == product.id);
                              final inCart = cartProv.groups.any((group) =>
                                  group.items.any((item) => item.productId == product.id));

                              return SupermarketProductCard(
                                product: product,
                                isFavorite: isFav,
                                isInCart: inCart,
                                onToggleFavorite: () async {
                                  if (isFav) {
                                    await favProv.removeFavorite(
                                      type: 'product',
                                      favoritableId: product.id,
                                    );
                                  } else {
                                    await favProv.addFavorite(
                                      type: 'product',
                                      favoritableId: product.id,
                                    );
                                  }
                                },
                                onAddToCart: () async {
                                  await cartProv.add(
                                    product.id,
                                    product.supermarketId,
                                    1,
                                  );
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductDetailsScreen(product: product),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
      ),
    );
  }
}
