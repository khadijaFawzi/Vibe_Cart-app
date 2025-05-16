// lib/screens/shopping_centers_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/models/supermarket.dart';
import 'package:vibe_cart/screens/center_products_screen.dart';
import 'package:vibe_cart/provider/supermarket_provider.dart';
import 'package:vibe_cart/utils/theme.dart';

class ShoppingCentersScreen extends StatefulWidget {
  const ShoppingCentersScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingCentersScreen> createState() => _ShoppingCentersScreenState();
}

class _ShoppingCentersScreenState extends State<ShoppingCentersScreen> {
  @override
  void initState() {
    super.initState();
    // جلب السوبرماركتات عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuperMarketProvider>().loadSupermarkets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final marketProv = context.watch<SuperMarketProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المراكز التجارية')),
        body: RefreshIndicator(
          onRefresh: () => context.read<SuperMarketProvider>().loadSupermarkets(),
          child: Builder(builder: (_) {
            if (marketProv.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              );
            } else if (marketProv.error.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('حدث خطأ: ${marketProv.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => marketProv.loadSupermarkets(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            } else if (marketProv.supermarkets.isEmpty) {
              return const Center(child: Text('لا توجد مراكز تجارية متاحة'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: marketProv.supermarkets.length,
              itemBuilder: (context, index) {
                final market = marketProv.supermarkets[index];
                return _buildMarketCard(context, market);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMarketCard(BuildContext context, SuperMarket market) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CenterProductsScreen(center: market),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // صورة المركز
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: market.profileImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          market.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.store, size: 40, color: AppColors.accent)),
                        ),
                      )
                    : const Center(child: Icon(Icons.store, size: 40, color: AppColors.accent)),
              ),
              const SizedBox(width: 16),
              // معلومات المركز
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(market.supermarketName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            market.location,
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(market.contactNumber,
                            style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
