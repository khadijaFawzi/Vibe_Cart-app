// lib/screens/shopping_centers_screen.dart
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:vibe_cart/models/center_model.dart';
import 'package:vibe_cart/screens/center_products_screen.dart';
import 'package:vibe_cart/services/provider_manager.dart';
import 'package:vibe_cart/utils/theme.dart';
 
class ShoppingCentersScreen extends StatefulWidget {
  const ShoppingCentersScreen({super.key});

  @override
  State<ShoppingCentersScreen> createState() => _ShoppingCentersScreenState();
}

class _ShoppingCentersScreenState extends State<ShoppingCentersScreen> {
  @override
  void initState() {
    super.initState();
    // جلب المراكز التجارية عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CenterProvider>().loadCenters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final centersProvider = context.watch<CenterProvider>();
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المراكز التجارية'),
        ),
        body: centersProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              )
            : centersProvider.error.isNotEmpty
                ? Center(
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
                          'حدث خطأ: ${centersProvider.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            centersProvider.loadCenters();
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : centersProvider.centers.isEmpty
                    ? const Center(
                        child: Text('لا توجد مراكز تجارية متاحة'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: centersProvider.centers.length,
                        itemBuilder: (context, index) {
                          final center = centersProvider.centers[index];
                          return _buildCenterItem(context, center);
                        },
                      ),
      ),
    );
  }
  
  Widget _buildCenterItem(BuildContext context, ShoppingCenter center) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CenterProductsScreen(center: center),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                child: center.logoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          center.logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.store,
                                size: 40,
                                color: AppColors.accent,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.store,
                          size: 40,
                          color: AppColors.accent,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // معلومات المركز
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (center.address != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              center.address!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    if (center.phoneNumber != null)
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            center.phoneNumber!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // سهم للانتقال
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
