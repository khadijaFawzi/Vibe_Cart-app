import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/provider/cart_provider.dart';
import 'package:vibe_cart/provider/favorites_provider.dart';
import 'package:vibe_cart/models/center_model.dart';
import 'package:vibe_cart/models/category_model.dart';
import 'package:vibe_cart/models/product.dart';
import 'package:vibe_cart/utils/theme.dart';
import 'package:vibe_cart/screens/product_details_screen.dart';

class CategoryInCenterScreen extends StatefulWidget {
  final ShoppingCenter center;
  final Category category;

  const CategoryInCenterScreen({
    Key? key,
    required this.center,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryInCenterScreen> createState() => _CategoryInCenterScreenState();
}

class _CategoryInCenterScreenState extends State<CategoryInCenterScreen> {
  bool _isLoading = true;
  String _error = '';
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    // Load cart and favorites to have data for state checks
    context.read<CartProvider>().loadCart();
    context.read<FavoritesProvider>().loadFavorites();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final all = await context
          .read<ProductProvider>()
          .getProductsBySupermarket(widget.center.id);
      _products = all
          .where((p) => p.categoryId == widget.category.id)
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
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
          title: Text('${widget.category.categoryName} - ${widget.center.name}'),
          backgroundColor: AppColors.accent,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              )
            : _error.isNotEmpty
                ? _buildErrorState()
                : _products.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (_, i) => _buildProductItem(_products[i]),
                        ),
                      ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('حدث خطأ: $_error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadProducts, child: const Text('إعادة المحاولة'))
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات في فئة ${widget.category.categoryName} في ${widget.center.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    final cartProv = context.watch<CartProvider>();
    final favProv = context.watch<FavoritesProvider>();
    // تحقق من وجود المنتج في العربة والمفضلة من بيانات الموفر
    final isInCart = cartProv.groups
        .any((g) => g.items.any((item) => item.productId == product.id));
    final isFav = favProv.favorites
        .any((fav) => fav.productId == product.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product, isFav),
            Expanded(child: _buildProductInfo(product, isInCart, cartProv)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product, bool isFav) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: product.image.isNotEmpty
                ? Image.network(product.image, fit: BoxFit.cover)
                : const Center(
                    child: Icon(Icons.local_grocery_store, size: 40, color: AppColors.accent),
                  ),
          ),
        ),
        if (product.isOffer)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
              // child: Text(
              //   'خصم ${product.discountPercentage?.toStringAsFixed(0)}%',
              //   style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              // ),
            ),
          ),
        Positioned(
          top: 8,
          left: 8,
          child: GestureDetector(
            onTap: () => _toggleFavorite(product, isFav),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey, size: 20),
            ),
          ),
        ),
      ],
    );
  }

 Widget _buildProductInfo(
  Product product,
  bool isInCart,
  CartProvider cartProv,
) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // اسم المنتج
        Text(
          product.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // عرض السعر أو سعر العرض
        product.isOffer ? _offerPrice(product) : _price(product),

        const Spacer(),

        // زر الإضافة
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isInCart
                ? null
                : () async {
                    try {
                      // نمرر فقط productId, supermarketId, quantity
                      await cartProv.add(
                        product.id,
                        widget.center.id,
                        1,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إضافة المنتج إلى العربة'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('حدث خطأ: $e'),
                        ),
                      );
                    }
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
  );
}


  Widget _price(Product product) => Text('${product.price.toStringAsFixed(0)} ر.س',
      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold));

  Widget _offerPrice(Product product) => Row(
        children: [
          // Text('${product.discountedPrice.toStringAsFixed(0)} ر.س',
          //     style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text('${product.price.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 10)),
        ],
      );

  void _toggleFavorite(Product product, bool isFav) async {
    final favProv = context.read<FavoritesProvider>();
    await favProv.toggleFavorite(product.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isFav ? 'تم إزالة المنتج من المفضلة' : 'تم إضافة المنتج إلى المفضلة'
          )
        )
      );
  }
}