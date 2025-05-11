// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:vibe_cart/screens/cart_screen.dart';
import 'package:vibe_cart/screens/favorites_screen.dart';
import 'package:vibe_cart/screens/settings_screen.dart';
import 'package:vibe_cart/services/provider_manager.dart';
import 'package:vibe_cart/utils/constants.dart';
import 'package:vibe_cart/utils/theme.dart';
import 'package:vibe_cart/widgets/category_item.dart';
import 'package:vibe_cart/widgets/offer_item.dart';
import 'package:vibe_cart/widgets/shopping_center_item.dart';
 

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
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
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
    // جلب البيانات عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadOffers();
      context.read<CategoryProvider>().loadCategories();
      context.read<CenterProvider>().loadCenters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Column(
          children: [
            // شريط العنوان المخصص
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                      setState(() {
                        // اختيار الحساب من شريط التنقل السفلي
                        (context.findAncestorStateOfType<_HomeScreenState>() as _HomeScreenState)
                            ._onItemTapped(3);
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // شريط البحث
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            
            // محتوى الصفحة المتبقي
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<ProductProvider>().loadOffers();
                  await context.read<CategoryProvider>().loadCategories();
                  await context.read<CenterProvider>().loadCenters();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العروض اليومية
                      const SizedBox(height: 16),
                      const Text(
                        'العروض اليومية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildOffers(),
                      
                      // الفئات
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
                      
                      // المراكز التجارية
                      const SizedBox(height: 24),
                      const Text(
                        'المراكز التجارية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCenters(),
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
  
  Widget _buildOffers() {
    final offersProvider = context.watch<ProductProvider>();
    
    if (offersProvider.isLoading) {
      return SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }
    
    if (offersProvider.error.isNotEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text('خطأ: ${offersProvider.error}'),
        ),
      );
    }
    
    if (offersProvider.offers.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text('لا توجد عروض متاحة حاليًا'),
        ),
      );
    }
    
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: offersProvider.offers.length,
        itemBuilder: (context, index) {
          final offer = offersProvider.offers[index];
          return OfferItem(product: offer);
        },
      ),
    );
  }
  
  Widget _buildCategories() {
    final categoriesProvider = context.watch<CategoryProvider>();
    
    if (categoriesProvider.isLoading) {
      return SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }
    
    if (categoriesProvider.error.isNotEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text('خطأ: ${categoriesProvider.error}'),
        ),
      );
    }
    
    if (categoriesProvider.categories.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('لا توجد فئات متاحة'),
        ),
      );
    }
    
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoriesProvider.categories.length,
        itemBuilder: (context, index) {
          final category = categoriesProvider.categories[index];
          return CategoryItem(
            category: category,
            icon: _getCategoryIcon(category.icon),
          );
        },
      ),
    );
  }
  
  IconData _getCategoryIcon(String iconName) {
    // تحويل اسم الأيقونة إلى الأيقونة المناسبة
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
  
  Widget _buildCenters() {
    final centersProvider = context.watch<CenterProvider>();
    
    if (centersProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    
    if (centersProvider.error.isNotEmpty) {
      return Center(
        child: Text('خطأ: ${centersProvider.error}'),
      );
    }
    
    if (centersProvider.centers.isEmpty) {
      return const Center(
        child: Text('لا توجد مراكز تجارية متاحة'),
      );
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
      itemCount: centersProvider.centers.length,
      itemBuilder: (context, index) {
        final center = centersProvider.centers[index];
        return ShoppingCenterItem(center: center);
      },
    );
  }
}
