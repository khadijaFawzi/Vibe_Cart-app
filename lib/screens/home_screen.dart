// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/models/category_model.dart';
import 'package:vibe_cart/provider/supermarket_provider.dart';
import 'package:vibe_cart/screens/center_products_screen.dart';
import 'package:vibe_cart/screens/shopping_centers_screen.dart';
import 'package:vibe_cart/services/provider_manager.dart';


import 'package:vibe_cart/api/category_provider.dart';

import 'package:vibe_cart/screens/cart_screen.dart';
import 'package:vibe_cart/screens/favorites_screen.dart';
import 'package:vibe_cart/screens/settings_screen.dart';

import 'package:vibe_cart/utils/constants.dart';
import 'package:vibe_cart/utils/theme.dart';
import 'package:vibe_cart/widgets/offer_item.dart';
import 'package:vibe_cart/models/supermarket.dart';


import '../api/category_provider.dart' show CategoryProvider;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const FavoritesScreen(),
    const CartScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
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
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<ProductProvider>().loadOffers();
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
            // شريط العنوان + أيقونة الإعدادات
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

            // المحتوى الرئيسي مع RefreshIndicator
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<ProductProvider>().loadProducts();
                  await context.read<ProductProvider>().loadOffers();
                  await context.read<CategoryProvider>().loadCategories();
                  await context.read<SuperMarketProvider>().loadSupermarkets();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== قسم الفئات =====
                      const SizedBox(height: 24),
                      const Text(
                        'الفئات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCategories(),

                      // ===== قسم العروض اليومية =====
                      const SizedBox(height: 24),
                      const Text(
                        'العروض اليومية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildOffers(),

                      // ===== قسم المراكز التجارية =====
                      const SizedBox(height: 24),
                      const Text(
                        'المراكز التجارية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSupermarkets(),
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

  /// دالة لإرجاع الأيقونة بناءً على اسم الفئة
  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'rice':
        return Icons.agriculture;
      case 'oil':
        return Icons.water_drop;
      case 'sugar':
        return Icons.cookie;
      case 'juice':
        return Icons.local_drink;
      case 'tuna':
        return Icons.set_meal;
      case 'chips':
        return Icons.fastfood;
      default:
        return Icons.category;
    }
  }

  Widget _buildCategories() {
    final catProvider = context.watch<CategoryProvider>();

    if (catProvider.isLoading) {
      return SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      );
    }
    if (catProvider.error.isNotEmpty) {
      return SizedBox(
        height: 100,
        child: Center(child: Text('خطأ: ${catProvider.error}')),
      );
    }
    if (catProvider.categories.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('لا توجد فئات متاحة')),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: catProvider.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final Category cat = catProvider.categories[index];
         final icon = _getCategoryIcon(cat.categoryName);

          return Column(
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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.accent, size: 32),
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
          );
        },
      ),
    );
  }

  Widget _buildOffers() {
    final offersProvider = context.watch<ProductProvider>();

    if (offersProvider.isLoading) {
      return SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      );
    }
    if (offersProvider.error.isNotEmpty) {
      return SizedBox(
        height: 180,
        child: Center(child: Text('خطأ: ${offersProvider.error}')),
      );
    }
    if (offersProvider.offers.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('لا توجد عروض متاحة حالياً')),
      );
    }
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: offersProvider.offers.length,
        itemBuilder: (context, index) =>
            OfferItem(product: offersProvider.offers[index]),
      ),
    );
  }

  Widget _buildSupermarkets() {
    final marketProvider = context.watch<SuperMarketProvider>();

    if (marketProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.accent),
        ),
      );
    }
    if (marketProvider.error.isNotEmpty) {
      return Center(child: Text('خطأ: ${marketProvider.error}'));
    }
    if (marketProvider.supermarkets.isEmpty) {
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
      itemCount: marketProvider.supermarkets.length,
      itemBuilder: (context, index) =>
          _buildSuperMarketCard(marketProvider.supermarkets[index]),
    );
  }

  Widget _buildSuperMarketCard(SuperMarket market) {
    return InkWell(
      onTap: () {
        // عند الضغط، ننقل لصفحة المنتجات الخاصة بالمركز
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShoppingCentersScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(market.imageUrl),
            ),
            const SizedBox(height: 8),
            Text(
              market.supermarketName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              market.location,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  } }