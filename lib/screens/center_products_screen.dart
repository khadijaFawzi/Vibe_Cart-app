// lib/screens/center_products_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/api/category_provider.dart';
import 'package:vibe_cart/models/center_model.dart';
import 'package:vibe_cart/models/product_supermarket_model.dart';
import 'package:vibe_cart/provider/productt_provider.dart';
import 'package:vibe_cart/services/provider_manager.dart';
import 'package:vibe_cart/utils/theme.dart';
import 'package:vibe_cart/models/category_model.dart';

import 'package:vibe_cart/screens/category_in_center_screen.dart';
import 'package:vibe_cart/screens/product_details_screen.dart';

class CenterProductsScreen extends StatefulWidget {
  final ShoppingCenter center;
  const CenterProductsScreen({
    super.key,
    required this.center,
  });

  @override
  State<CenterProductsScreen> createState() => _CenterProductsScreenState();
}

class _CenterProductsScreenState extends State<CenterProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _error = '';
  List<Product> _centerProducts = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // جلب الفئات
      final categoryProvider = context.read<CategoryProvider>();
      if (categoryProvider.categories.isEmpty) {
        await categoryProvider.loadCategories();
      }
      _categories = categoryProvider.categories;

      // إعداد مراقب التبويبات
      _tabController = TabController(
        length: _categories.length,
        vsync: this,
      );

      // جلب وتنقية منتجات المركز بدون تكرار حسب الباركود
      // final prodProv = context.read<ProductProvider>();
      // if (prodProv.products.isEmpty) {
      //   await prodProv.loadProducts();
      // }
      // final unique = prodProv.uniqueProducts;
      // _centerProducts = unique
      //     .where((p) => p.supermarket == widget.center.name)
      //     .toList();

      setState(() {
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.center.name),
          backgroundColor: AppColors.accent,
          bottom: !_isLoading && _error.isEmpty
              ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.accent,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.accent,
                  tabs: _categories
                      .map((cat) => Tab(text: cat.categoryName))
                      .toList(),
                )
              : null,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              )
            : _error.isNotEmpty
                ? _buildErrorState()
                : TabBarView(
                    controller: _tabController,
                    children:
                        _categories.map((cat) => _buildCategoryTab(cat)).toList(),
                  ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            onPressed: _loadData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(Category category) {
    final categoryProducts = _centerProducts
        .where((product) => product.categoryId == category.id)
        .toList();

    if (categoryProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.category_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات في فئة ${category.categoryName}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryInCenterScreen(
                      center: widget.center,
                      category: category,
                    ),
                  ),
                );
              },
              child: const Text('عرض جميع منتجات الفئة'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categoryProducts.length,
        itemBuilder: (context, index) {
          final product = categoryProducts[index];
          return _buildProductItem(context, product);
        },
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    final cartProv = context.watch<CartProvider>();
    final favProv = context.watch<FavoritesProvider>();

    final isInCart = cartProv.isInCart(product.id);
    final isInFav = favProv.isInFavorites(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
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
            _buildProductImage(context, product, favProv),
            _buildProductInfo(product, isInCart, cartProv),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(
      BuildContext context, Product product, FavoritesProvider favProv) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.local_grocery_store,
                        size: 40,
                        color: AppColors.accent,
                      ),
                    ),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            onTap: () => _toggleFavorite(product),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                favProv.isInFavorites(product.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favProv.isInFavorites(product.id)
                    ? Colors.red
                    : Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(
      Product product, bool isInCart, CartProvider cartProv) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (product.isOffer) _buildOfferPrice(product) else _buildPrice(product),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isInCart
                    ? null
                    : () {
                        cartProv.addToCart(product);
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
    );
  }

  Widget _buildPrice(Product product) => Text(
        '${product.price.toStringAsFixed(0)} ريال',
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _buildOfferPrice(Product product) => Row(
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
      );

  void _toggleFavorite(Product product) {
    final favProv = context.read<FavoritesProvider>();
    if (favProv.isInFavorites(product.id)) {
      favProv.removeFromFavorites(product.id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تم إزالة من المفضلة')));
    } else {
      favProv.addToFavorites(product);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تم إضافة إلى المفضلة')));
    }
  }
}
