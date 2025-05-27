import 'package:flutter/material.dart';
import 'package:vibe_cart/models/product.dart';
import 'package:vibe_cart/screens/price_comparison_screen.dart'; // أو صفحة التفاصيل الخاصة بك

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String imageUrl;
    if (product.image.startsWith('http')) {
      imageUrl = product.image;
    } else if (product.image.endsWith('.jpg') ||
        product.image.endsWith('.jpeg') ||
        product.image.endsWith('.png')) {
      imageUrl = 'http://192.168.1.107:8000/products/${product.image}';
    } else {
      imageUrl = '';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // انتقل إلى صفحة مقارنة الأسعار أو صفحة تفاصيل المنتج
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PriceComparisonScreen(barcode: product.barcode),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة المنتج (كبيرة)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
              ),
            ),
            // اسم المنتج أسفل البطاقة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Text(
                product.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  color: Color(0xFF263238),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
