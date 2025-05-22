// lib/widgets/price_comparison_card.dart

import 'package:flutter/material.dart';
import 'package:vibe_cart/models/price_comparison.dart';
import 'package:vibe_cart/utils/theme.dart';

class PriceComparisonCard extends StatelessWidget {
  final PriceComparison comparison;
  const PriceComparisonCard({
    Key? key,
    required this.comparison,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bestPrice = comparison.minPrice;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عنوان المنتج
            Text(
              comparison.productName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // أفضل سعر والتوفير
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text('أفضل سعر', style: TextStyle(color: Colors.green)),
                    const SizedBox(height: 4),
                    Text('${bestPrice.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                Column(
                  children: [
                    const Text('وفّرت', style: TextStyle(color: Colors.blueAccent)),
                    const SizedBox(height: 4),
                    Text('${comparison.saving.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  ],
                ),
                Column(
                  children: [
                    const Text('أعلى سعر', style: TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 4),
                    Text('${comparison.maxPrice.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            // قائمة العروض
            Text(
              'العروض حسب المركز',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            ...comparison.offers.map((offer) {
              final isBest = offer.price == bestPrice;
              final diff = offer.price - bestPrice;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // أيقونة أو صورة المصغرة
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        offer.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.store, color: AppColors.accent),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        offer.supermarketName,
                        style: TextStyle(
                          fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                          color: isBest ? Colors.green : null,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${offer.price.toStringAsFixed(0)} ر.س',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isBest ? Colors.green : null,
                            )),
                        if (!isBest)
                          Text('+${diff.toStringAsFixed(0)} ر.س',
                              style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
