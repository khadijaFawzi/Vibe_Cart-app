import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/models/offer.dart';
import 'package:vibe_cart/utils/theme.dart';

class OfferDetailsScreen extends StatefulWidget {
  final Offer offer;
  const OfferDetailsScreen({Key? key, required this.offer}) : super(key: key);

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;

    // أولوية الصورة: صورة المنتج، ثم صورة العرض، ثم صورة افتراضية
    String? imageUrl;
    if (offer.productImage != null && offer.productImage!.isNotEmpty) {
      imageUrl = offer.productImage;
    } else if (offer.offerImage != null && offer.offerImage!.isNotEmpty) {
      imageUrl = offer.offerImage;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل العرض'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة العرض/المنتج
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[100],
                child: (imageUrl != null)
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 100,
                            color: AppColors.accent,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: AppColors.accent,
                        ),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (offer.supermarketName != null &&
                        offer.supermarketName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.store,
                                size: 18, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text(
                              offer.supermarketName!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      offer.productName ?? 'بدون اسم منتج',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (offer.discountPercentage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${offer.discountPercentage!.toStringAsFixed(1)}% خصم',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),

                    if (offer.startDate != null && offer.endDate != null)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'من ${offer.startDate!.toString().split(' ')[0]} إلى ${offer.endDate!.toString().split(' ')[0]}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),

                    if (offer.description != null &&
                        offer.description!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الوصف',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            offer.description!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    const SizedBox(height: 14),

                    if (offer.extractedText != null &&
                        offer.extractedText!.isNotEmpty)
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'نص العرض المستخرج:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.blue),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                offer.extractedText!,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    const Text(
                      'الكمية',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed:
                              _quantity > 1 ? () => setState(() => _quantity--) : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // زري "اطلب الآن" و"أضف للعربة" بدون تفعيل
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: null, // معطل
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12)),
                            child: const Text('اطلب الآن'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: null, // معطل
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('أضف للعربة'),
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
      ),
    );
  }
}
