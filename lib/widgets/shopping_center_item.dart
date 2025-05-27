// lib/widgets/shopping_center_item.dart

import 'package:flutter/material.dart';
import 'package:vibe_cart/models/supermarket.dart';                // تغير الاستيراد
import 'package:vibe_cart/screens/center_products_screen.dart';     // يحتوي على SupermarketProductsScreen
import 'package:vibe_cart/utils/theme.dart';

class ShoppingCenterItem extends StatelessWidget {
  final SuperMarket supermarket;                               // تغيير النوع والاسم
  
  const ShoppingCenterItem({
    Key? key,
    required this.supermarket,                                 // تغيير المعامل
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SupermarketMainScreen(
              supermarket: supermarket,                          // تمرير المعامل الصحيح
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store,
              size: 40,
              color: AppColors.accent,
            ),
            const SizedBox(height: 12),
            Text(
              supermarket.supermarketName,                     // حقل الاسم
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'تسوق الآن',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
