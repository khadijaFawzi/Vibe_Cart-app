// lib/widgets/product_item.dart
import 'package:flutter/material.dart';
import 'package:vibe_cart/models/product_supermarket_model.dart';
import 'package:vibe_cart/screens/product_details_screen.dart';
import 'package:vibe_cart/utils/theme.dart';


class ProductItem extends StatelessWidget {
  final Product product;
  
  const ProductItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: product.imageUrl.isNotEmpty
                    ? Image.asset(
          'assets/images/google_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.local_grocery_store,
                              size: 40,
                              color: AppColors.accent,
                            ),
                          );
                        },
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
            // تفاصيل المنتج
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  product.isOffer
                      ? Row(
                          children: [
                            Text(
                              '${product.discountedPrice.toStringAsFixed(0)} ريال',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${product.price.toStringAsFixed(0)} ريال',
                              style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          '${product.price.toStringAsFixed(0)} ريال',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
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
}
