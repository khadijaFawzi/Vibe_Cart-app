import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:provider/provider.dart';
import 'package:vibe_cart/api/category_provider.dart';
import 'package:vibe_cart/models/product.dart';
import 'package:vibe_cart/provider/food_basket_provider.dart';
import 'package:vibe_cart/provider/offers_provider.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/provider/supermarket_provider.dart';
import 'package:vibe_cart/screens/all_categories_screen.dart';
import 'package:vibe_cart/screens/all_products_screen.dart';
import 'package:vibe_cart/screens/all_offers_screen.dart';
import 'package:vibe_cart/screens/FoodBasketDetailsScreen.dart';
import 'package:vibe_cart/screens/all_food_baskets_screen.dart';
import 'package:vibe_cart/screens/all_supermarkets_screen.dart';
import 'package:vibe_cart/screens/cart_screen.dart';
import 'package:vibe_cart/screens/category_screen.dart';
import 'package:vibe_cart/screens/center_products_screen.dart';
import 'package:vibe_cart/screens/favorites_screen.dart';
import 'package:vibe_cart/screens/offer_details_screen.dart';
import 'package:vibe_cart/screens/price_comparison_screen.dart';
import 'package:vibe_cart/screens/settings_screen.dart';
import 'package:vibe_cart/utils/constants.dart';
import 'package:vibe_cart/utils/icon_helper.dart';
import 'package:vibe_cart/utils/theme.dart';
import 'package:vibe_cart/widgets/product_item.dart';

const Color discountRed = Color.fromARGB(255, 206, 59, 22);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _pages = <Widget>[
    const HomePageContent(),
    const FavoritesScreen(),
    const CartScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'المفضلة',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'العربة',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'الحساب',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.accent,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  late PageController _offerPageController;
  int _currentOfferIndex = 0;
  Timer? _offerTimer;

  // ---- إضافة متغيرات البحث ----
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  // ---------------------------

  @override
  void initState() {
    super.initState();
    _offerPageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProductProvider>().loadProducts();
      _allProducts = context.read<ProductProvider>().products;
      setState(() {
        _filteredProducts = _allProducts;
      });

      context.read<OffersProvider>().loadOffers();
      context.read<CategoryProvider>().loadCategories();
      context.read<SuperMarketProvider>().loadSupermarkets();
      context.read<FoodBasketProvider>().fetchAllFoodBaskets();
      _startOfferRotation();
    });

    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  // ---- دالة البحث ----
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      _filteredProducts = _allProducts
          .where((product) => product.productName.contains(query))
          .toList();
    });
  }
  // -------------------

  void _startOfferRotation() {
    _offerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final offers = context.read<OffersProvider>().offers;
      if (offers.isNotEmpty) {
        _currentOfferIndex = (_currentOfferIndex + 1) % offers.length;
        _offerPageController.animateToPage(
          _currentOfferIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    _offerPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Column(
          children: [
            // عنوان التطبيق والإعدادات
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                      Text(
                        AppConstants.appSlogan,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      (context.findAncestorStateOfType<_HomeScreenState>()!)
                          ._onItemTapped(3);
                    },
                  ),
                ],
              ),
            ),

            // شريط البحث
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتجات...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                ),
              ),
            ),

            // المحتوى الرئيسي
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<ProductProvider>().loadProducts();
                  await context.read<OffersProvider>().loadOffers();
                  await context.read<CategoryProvider>().loadCategories();
                  await context.read<SuperMarketProvider>().loadSupermarkets();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // الفئات
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الفئات',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) =>  AllCategoriesScreen()),
                              );
                            },
                            child: Text(
                              'عرض الكل',
                              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCategories(),

                      const SizedBox(height: 24),
                      // المراكز التجارية
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'المراكز التجارية',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AllSupermarketsScreen()),
                              );
                            },
                            child: Text(
                              'عرض الكل',
                              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSupermarkets(),

                      const SizedBox(height: 24),
                      // عروض المنتجات
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            ' عروض المنتجات',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AllOffersScreen()),
                              );
                            },
                            child: Text(
                              'عرض الكل',
                              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildOffers(),

                      const SizedBox(height: 24),
                      // السلات الغذائية
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'السلات الغذائية',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AllFoodBasketsScreen()),
                              );
                            },
                            child: Text(
                              'عرض الكل',
                              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildFoodBaskets(),

                      const SizedBox(height: 24),
                      // أحدث المنتجات مع البحث
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'أحدث المنتجات',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AllLatestProductsScreen()),
                              );
                            },
                            child: Text(
                              'عرض الكل',
                              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildLatestProducts(), // سيتم اظهار نتائج البحث هنا إذا كان هناك نص
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildCategories() {
  final catProv = context.watch<CategoryProvider>();
  if (catProv.isLoading) {
    return const SizedBox(
      height: 100,
      child: Center(child: CircularProgressIndicator()),
    );
  }
  if (catProv.error.isNotEmpty) {
    return SizedBox(
      height: 100,
      child: Center(child: Text('خطأ: ${catProv.error}')),
    );
  }
  if (catProv.categories.isEmpty) {
    return const SizedBox(
      height: 100,
      child: Center(child: Text('لا توجد فئات متاحة')),
    );
  }
  return SizedBox(
    height: 100,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: catProv.categories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final cat = catProv.categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryProductsScreen(category: cat),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: (cat.icon != null && cat.icon!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image(
                          image: cat.icon!.startsWith('http')
                              ? NetworkImage(cat.icon!)
                              : AssetImage(cat.icon!) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        getCategoryIcon(cat.categoryName),
                        color: AppColors.accent,
                        size: 32,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                cat.categoryName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
Widget _buildSupermarkets() {
  final marketProv = context.watch<SuperMarketProvider>();

  if (marketProv.isLoading) {
    return Center(child: CircularProgressIndicator());
  }
  if (marketProv.error.isNotEmpty) {
    return Center(child: Text('خطأ: ${marketProv.error}'));
  }
  if (marketProv.supermarkets.isEmpty) {
    return Center(child: Text('لا توجد سوبرماركتات متاحة حالياً'));
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.70,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: marketProv.supermarkets.length,
      itemBuilder: (ctx, i) {
        final m = marketProv.supermarkets[i];
        return _buildSupermarketCircleCard(context, m);
      },
    ),
  );
}

Widget _buildSupermarketCircleCard(BuildContext context, dynamic m) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SupermarketMainScreen(supermarket: m)),
      );
    },
    borderRadius: BorderRadius.circular(22),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF234D59).withOpacity(.09),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF5C8076).withOpacity(.09),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // الصورة الدائرية
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5C8076).withOpacity(.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[100],
              backgroundImage: m.imageUrl != null && m.imageUrl.isNotEmpty
                  ? NetworkImage(m.imageUrl)
                  : null,
              child: (m.imageUrl == null || m.imageUrl.isEmpty)
                  ? const Icon(Icons.store, size: 26, color: Color(0xFF5C8076))
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              children: [
                Text(
                  m.supermarketName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF234D59),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, size: 10, color: Color(0xFF5C8076)),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        m.location ?? '',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C8076).withOpacity(.13),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'تصفح المنتجات',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C8076),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildOffers() {
  final prov = context.watch<OffersProvider>();

  if (prov.isLoadingOffers) {
    return SizedBox(
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
              'الفترة: ${DateFormat('yyyy-MM-dd').format(offer.startDate!)} إلى ${DateFormat('yyyy-MM-dd').format(offer.endDate!)}';
        } else if (offer.startDate != null) {
          dateRange =
              'يبدأ: ${DateFormat('yyyy-MM-dd').format(offer.startDate!)}';
        } else if (offer.endDate != null) {
          dateRange =
              'ينتهي: ${DateFormat('yyyy-MM-dd').format(offer.endDate!)}';
        }

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OfferDetailsScreen(offer: offer),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // صورة المنتج
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                  child: Container(
                    width: 125,
                    height: double.infinity,
                    color: Colors.grey[100],
                    child: offer.productImage != null &&
                            offer.productImage!.isNotEmpty
                        ? Image.network(
                            offer.productImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image, size: 60, color: Colors.grey),
                          )
                        : const Icon(Icons.image, size: 60, color: Colors.grey),
                  ),
                ),
                // معلومات العرض
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
                                onPressed: () {},
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.shopping_cart_outlined),
                                color: Colors.teal.shade700,
                                iconSize: 22,
                                onPressed: () {},
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

Widget _buildFoodBaskets() {
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
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => FoodBasketDetailsScreen(basket: basket)));
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة السلة بالأعلى
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: AspectRatio(
                  aspectRatio: 1.6,
                  child: basket.image != null && basket.image!.isNotEmpty
                      ? Image.network(
                          'http://192.168.1.107:8000/storage/${basket.image}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 60, color: Colors.grey),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 80, color: Colors.grey),
                        ),
                ),
              ),
              // السعر واسم السوبرماركت في الأسفل
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

  Widget _buildLatestProducts() {
    final prodProv = context.watch<ProductProvider>();
    if (_isSearching) {
      if (_filteredProducts.isEmpty) {
        return const Center(child: Text('لا توجد نتائج للبحث'));
      }
      return GridView.builder(
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
          final p = _filteredProducts[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PriceComparisonScreen(barcode: p.barcode)),
              );
            },
            child: ProductItem(product: p),
          );
        },
      );
    }

    // الكود الأصلي القديم هنا كما هو
    if (prodProv.isLoading) {
      return SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accent)),
        ),
      );
    }
    if (prodProv.error.isNotEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('خطأ: ${prodProv.error}')),
      );
    }
    if (prodProv.products.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('لا توجد منتجات متاحة حالياً')),
      );
    }

    // إزالة التكرارات
    final all = prodProv.products;
    final uniqueMap = <String, Product>{};
    for (var p in all) {
      final key = p.barcode.isNotEmpty ? p.barcode : p.productName;
      uniqueMap.putIfAbsent(key, () => p);
    }
    final uniqueList = uniqueMap.values.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: uniqueList.length,
      itemBuilder: (ctx, i) {
        final p = uniqueList[i];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PriceComparisonScreen(barcode: p.barcode)),
            );
          },
          child: ProductItem(product: p),
        );
      },
    );
  }
}
