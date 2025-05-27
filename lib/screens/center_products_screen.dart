import 'dart:async';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:vibe_cart/models/supermarket.dart';
import 'package:vibe_cart/models/category_model.dart';
import 'package:vibe_cart/models/product.dart';
import 'package:vibe_cart/models/food_basket.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/provider/favorites_provider.dart';
import 'package:vibe_cart/provider/cart_provider.dart';
import 'package:vibe_cart/provider/offers_provider.dart';
import 'package:vibe_cart/provider/food_basket_provider.dart';
import 'package:vibe_cart/screens/FoodBasketDetailsScreen.dart';
import 'package:vibe_cart/screens/category_in_center_screen.dart';
import 'package:vibe_cart/screens/product_details_screen.dart';
import 'package:vibe_cart/screens/offer_details_screen.dart';
import 'package:vibe_cart/widgets/supermarket_product_card.dart';
import 'package:vibe_cart/utils/theme.dart';

String formatDate(DateTime? date) {
  if (date == null) return '';
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
}

class SupermarketMainScreen extends StatefulWidget {
  final SuperMarket supermarket;
  const SupermarketMainScreen({Key? key, required this.supermarket}) : super(key: key);

  @override
  State<SupermarketMainScreen> createState() => _SupermarketMainScreenState();
}

class _SupermarketMainScreenState extends State<SupermarketMainScreen> {
  late PageController _offerPageController;
  late PageController _basketPageController;
  int _currentOfferIndex = 0;
  int _currentBasketIndex = 0;
  Timer? _offerTimer;
  Timer? _basketTimer;
  final TextEditingController _searchController = TextEditingController();

  List<Category> _categories = [];
  List<Product> _products = [];
  List _offers = [];
  List<FoodBasket> _foodBaskets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _offerPageController = PageController(initialPage: 0);
    _basketPageController = PageController(initialPage: 0);
    _loadData();
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    _basketTimer?.cancel();
    _offerPageController.dispose();
    _basketPageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _categories = await context.read<ProductProvider>().fetchCategoriesBySupermarket(widget.supermarket.id);
    _products = await context.read<ProductProvider>().getProductsBySupermarket(widget.supermarket.id);
    _offers = await context.read<OffersProvider>().loadOffersBySupermarket(widget.supermarket.id);
    await context.read<FoodBasketProvider>().fetchFoodBaskets(widget.supermarket.id);
    _foodBaskets = context.read<FoodBasketProvider>().foodBaskets;

    setState(() => _isLoading = false);
    _startOfferRotation();
    _startBasketRotation();
  }

  void _startOfferRotation() {
    _offerTimer?.cancel();
    if (_offers.isNotEmpty) {
      _offerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_offerPageController.hasClients) {
          _currentOfferIndex = (_currentOfferIndex + 1) % _offers.length;
          _offerPageController.animateToPage(
            _currentOfferIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _startBasketRotation() {
    _basketTimer?.cancel();
    if (_foodBaskets.isNotEmpty) {
      _basketTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_basketPageController.hasClients) {
          _currentBasketIndex = (_currentBasketIndex + 1) % _foodBaskets.length;
          _basketPageController.animateToPage(
            _currentBasketIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  List<Product> get _filteredProducts {
    final query = _searchController.text.trim();
    if (query.isEmpty) return _products;
    return _products.where((p) => p.productName.contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.supermarket.supermarketName, maxLines: 1, overflow: TextOverflow.ellipsis),
          backgroundColor: AppColors.accent,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSupermarketHeader(),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن منتج في هذا السوبرماركت...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        if (_categories.isNotEmpty) ...[
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text('الفئات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 12),
                          _buildCategoriesRow(_categories),
                          const SizedBox(height: 20),
                        ],

                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text('العروض', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        _buildOffersCarousel(),
                        const SizedBox(height: 22),

                        if (_foodBaskets.isNotEmpty) ...[
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text('السلات الغذائية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 12),
                          _buildFoodBasketsPageView(),
                          const SizedBox(height: 22),
                        ],

                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text('المنتجات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        _filteredProducts.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: Center(child: Text('لا توجد منتجات')),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.7,
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (ctx, i) {
                                  final product = _filteredProducts[i];
                                  final isFavorite = favoritesProvider.favorites
                                      .any((f) => f.type == 'product' && f.productId == product.id);
                                  final inCart = cartProvider.groups.any((g) =>
                                      g.items.any((item) => item.productId == product.id));

                                  return SupermarketProductCard(
                                    product: product,
                                    isFavorite: isFavorite,
                                    isInCart: inCart,
                                    onToggleFavorite: () async {
                                      if (isFavorite) {
                                        await favoritesProvider.removeFavorite(
                                          type: 'product',
                                          favoritableId: product.id,
                                        );
                                      } else {
                                        await favoritesProvider.addFavorite(
                                          type: 'product',
                                          favoritableId: product.id,
                                        );
                                      }
                                    },
                                    onAddToCart: () async {
                                      await cartProvider.add(
                                        product.id,
                                        product.supermarketId,
                                        1,
                                      );
                                    },
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailsScreen(product: product),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                        const SizedBox(height: 34),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSupermarketHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          CircleAvatar(
            radius: 44,
            backgroundImage: NetworkImage(widget.supermarket.imageUrl),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 8),
          Text(widget.supermarket.supermarketName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 21)),
          if (widget.supermarket.location.isNotEmpty)
            Text(widget.supermarket.location, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow(List<Category> categories) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SupermarketCategoryProductsScreen(
                    supermarketId: widget.supermarket.id,
                    category: cat,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: cat.icon != null && cat.icon!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: cat.icon!.startsWith('http')
                              ? Image.network(cat.icon!, fit: BoxFit.cover)
                              : Image.asset(cat.icon!, fit: BoxFit.cover),
                        )
                      : Icon(Icons.category, size: 30, color: AppColors.accent),
                ),
                const SizedBox(height: 8),
                Text(cat.categoryName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOffersCarousel() {
    final prov = context.watch<OffersProvider>();

    if (prov.isLoadingOffers) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (prov.offersError.isNotEmpty) {
      return SizedBox(
        height: 220,
        child: Center(child: Text('خطأ: ${prov.offersError}')),
      );
    }
    if (prov.offers.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('لا توجد عروض متاحة')),
      );
    }

    return SizedBox(
      height: 260,
      child: PageView.builder(
        itemCount: prov.offers.length,
        controller: _offerPageController,
        itemBuilder: (context, index) {
          final offer = prov.offers[index];
          String dateRange = '';
          if (offer.startDate != null && offer.endDate != null) {
            dateRange =
                'الفترة: ${formatDate(offer.startDate)} إلى ${formatDate(offer.endDate)}';
          } else if (offer.startDate != null) {
            dateRange = 'يبدأ: ${formatDate(offer.startDate)}';
          } else if (offer.endDate != null) {
            dateRange = 'ينتهي: ${formatDate(offer.endDate)}';
          }

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OfferDetailsScreen(offer: offer)),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                    child: Container(
                      width: 125,
                      height: double.infinity,
                      color: Colors.grey[100],
                      child: offer.productImage != null && offer.productImage!.isNotEmpty
                          ? Image.network(
                              offer.productImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, size: 60, color: Colors.grey),
                            )
                          : const Icon(Icons.image, size: 60, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (offer.discountPercentage != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${offer.discountPercentage!.toStringAsFixed(0)}% خصم',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Text(
                            offer.productName ?? 'منتج',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF234D59),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (offer.supermarketName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                offer.supermarketName!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (dateRange.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                dateRange,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF00796B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (offer.discountedPrice != null && offer.originalPrice != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Text(
                                    '${offer.originalPrice!.toStringAsFixed(2)} ر.ي',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${offer.discountedPrice!.toStringAsFixed(2)} ر.ي',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.favorite_border),
                                  color: Colors.red.shade400,
                                  iconSize: 22,
                                  onPressed: () {
                                    // هنا يمكنك استدعاء favoritesProvider.add/removeOffer
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.shopping_cart_outlined),
                                  color: Colors.teal.shade700,
                                  iconSize: 22,
                                  onPressed: () {
                                    // هنا يمكنك استدعاء cartProvider.add
                                  },
                                ),
                              ],
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
        },
      ),
    );
  }

  Widget _buildFoodBasketsPageView() {
    final basketProv = context.watch<FoodBasketProvider>();

    if (basketProv.isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (basketProv.error.isNotEmpty) {
      return SizedBox(
        height: 220,
        child: Center(child: Text('خطأ: ${basketProv.error}')),
      );
    }
    if (basketProv.foodBaskets.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('لا توجد سلات غذائية متاحة')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: basketProv.foodBaskets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final basket = basketProv.foodBaskets[index];
        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FoodBasketDetailsScreen(basket: basket)),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 4)),
              ],  
            ),  
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: basket.image != null && basket.image!.isNotEmpty
                        ? Image.network(
                            'http://192.168.1.107:8000/storage/${basket.image}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image, size: 60, color: Colors.grey),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 80, color: Colors.grey),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'السعر: ${basket.price.toStringAsFixed(2)} ر.ي',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1A8B35),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.storefront, color: Color(0xFF234D59), size: 18),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              basket.supermarket?.supermarketName ?? 'غير معروف',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (basket.startDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF234D59), size: 17),
                              const SizedBox(width: 5),
                              Text(
                                'تاريخ الإضافة: ${formatDate(DateTime.parse(basket.startDate!))}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
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
    );
  }
}
