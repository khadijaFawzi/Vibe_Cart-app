import 'package:flutter/material.dart';
import 'package:vibe_cart/models/offer.dart';

class OfferItem extends StatelessWidget {
  final Offer offer;
  const OfferItem({
    Key? key,
    required this.offer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // نفس طريقة المنتجات:
    final String imageUrl;
    if (offer.productImage != null && offer.productImage!.startsWith('http')) {
      imageUrl = offer.productImage!;
    } else if (offer.productImage != null &&
        (offer.productImage!.endsWith('.jpg') ||
            offer.productImage!.endsWith('.jpeg') ||
            offer.productImage!.endsWith('.png'))) {
   imageUrl = 'http://192.168.1.107:8000/products/${offer.productImage}';
    } else {
      imageUrl = '';
    }

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16, bottom: 16),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // هنا تفتح صفحة تفاصيل العرض أو المنتج لو أحببت
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة العرض/المنتج
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.productName ?? 'اسم المنتج',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (offer.discountPercentage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${offer.discountPercentage!.toStringAsFixed(0)}% خصم',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (offer.supermarketName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        offer.supermarketName!,
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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
