import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/api/category_provider.dart';
import 'package:vibe_cart/models/product.dart';
import 'package:vibe_cart/models/offer.dart';
import 'package:vibe_cart/provider/offers_provider.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/provider/supermarket_provider.dart';
import 'package:vibe_cart/screens/cart_screen.dart';
import 'package:vibe_cart/screens/category_screen.dart';
import 'package:vibe_cart/screens/center_products_screen.dart';
import 'package:vibe_cart/screens/favorites_screen.dart';
import 'package:vibe_cart/screens/price_comparison_screen.dart';
import 'package:vibe_cart/screens/settings_screen.dart';
import 'package:vibe_cart/utils/constants.dart';
import 'package:vibe_cart/utils/theme.dart';
import 'package:vibe_cart/widgets/product_item.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<OffersProvider>().loadOffers();
      context.read<CategoryProvider>().loadCategories();
      context.read<SuperMarketProvider>().loadSupermarkets();
    });
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
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتجات...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
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
                      // قسم الفئات
                      const SizedBox(height: 24),
                      const Text(
                        'الفئات',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildCategories(),

                      // قسم المراكز التجارية (بعد الفئات)
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'المراكز التجارية',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {/* عرض الكل */},
                            child: Text(
                              'عرض الكل',
                              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSupermarkets(),

                      // قسم العروض اليومية
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'العروض اليومية',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {/* عرض الكل */},
                            child: Text(
                              'عرض الكل',
                              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildOffers(),

                      // قسم أحدث المنتجات
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'أحدث المنتجات',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {/* عرض الكل */},
                            child: Text(
                              'عرض الكل',
                              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildLatestProducts(),
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
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withOpacity(0.2),
                AppColors.accent.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: cat.icon != null && cat.icon!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image(
                    image: cat.icon!.startsWith('http')
                        ? NetworkImage(cat.icon!)
                        : AssetImage(cat.icon!) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(Icons.category, color: AppColors.accent, size: 32),
        ),
        const SizedBox(height: 8),
        Text(cat.categoryName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
      return const Center(child: CircularProgressIndicator());
    }
    if (marketProv.error.isNotEmpty) {
      return Center(child: Text('خطأ: ${marketProv.error}'));
    }
    if (marketProv.supermarkets.isEmpty) {
      return const Center(child: Text('لا توجد سوبرماركتات متاحة حالياً'));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: marketProv.supermarkets.length,
      itemBuilder: (ctx, i) {
        final m = marketProv.supermarkets[i];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SupermarketProductsScreen(supermarket: m),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(m.imageUrl),
                  onBackgroundImageError: (_, __) {},
                  child: m.imageUrl.isEmpty ? Icon(Icons.store, size: 30, color: Colors.grey) : null,
                ),
                const SizedBox(height: 8),
                Text(
                  m.supermarketName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  m.location,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOffers() {
    final prov = context.watch<OffersProvider>();
    if (prov.isLoadingOffers) {
      return SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accent)),
        ),
      );
    }
    if (prov.offersError.isNotEmpty) {
      return SizedBox(
        height: 140,
        child: Center(child: Text('خطأ: ${prov.offersError}')),
      );
    }
    if (prov.offers.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(child: Text('لا توجد عروض متاحة')),
      );
    }
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: prov.offers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final offer = prov.offers[i];
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: offer.productImage != null && offer.productImage!.isNotEmpty
                          ? Image.network(
                              offer.productImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: Colors.grey),
                            )
                          : const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.productName ?? 'منتج',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (offer.supermarketName != null)
                          Text(
                            offer.supermarketName!,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (offer.description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              offer.description!,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (offer.discountPercentage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${offer.discountPercentage!.toStringAsFixed(0)}% خصم',
                              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
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
    );
  }

  Widget _buildLatestProducts() {
    final prodProv = context.watch<ProductProvider>();
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
