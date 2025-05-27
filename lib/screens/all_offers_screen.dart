// lib/screens/all_offers_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/provider/offers_provider.dart';
import 'package:vibe_cart/screens/offer_details_screen.dart';

class AllOffersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final offersProv = context.watch<OffersProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('جميع العروض'),
        ),
        body: offersProv.isLoadingOffers
            ? const Center(child: CircularProgressIndicator())
            : offersProv.offers.isEmpty
                ? const Center(child: Text('لا توجد عروض متاحة'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: offersProv.offers.length,
                    itemBuilder: (ctx, i) {
                      final offer = offersProv.offers[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OfferDetailsScreen(offer: offer),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.09),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // صورة المنتج (يمين)
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                                child: offer.productImage != null && offer.productImage!.isNotEmpty
                                    ? Image.network(
                                        offer.productImage!,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              // معلومات المنتج (شمال)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        offer.productName ?? 'بدون اسم',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF234D59),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.red[600],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${offer.discountPercentage?.toStringAsFixed(0) ?? '0'}% خصم',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (offer.originalPrice != null && offer.discountedPrice != null)
                                            Row(
                                              children: [
                                                Text(
                                                  '${offer.originalPrice!.toStringAsFixed(2)} ر.ي',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    decoration: TextDecoration.lineThrough,
                                                  ),
                                                ),
                                                const SizedBox(width: 7),
                                                Text(
                                                  '${offer.discountedPrice!.toStringAsFixed(2)} ر.ي',
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      if (offer.startDate != null && offer.endDate != null)
                                        Text(
                                          'الفترة: ${_formatDate(offer.startDate)} إلى ${_formatDate(offer.endDate)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.teal,
                                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}
