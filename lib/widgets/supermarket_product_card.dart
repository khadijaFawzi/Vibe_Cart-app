import 'package:flutter/material.dart';
import 'package:vibe_cart/models/product.dart';

class SupermarketProductCard extends StatelessWidget {
  final Product product;
  final bool isInCart;
  final bool isFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onTap;

  const SupermarketProductCard({
    Key? key,
    required this.product,
    required this.isInCart,
    required this.isFavorite,
    required this.onAddToCart,
    required this.onToggleFavorite,
    this.onTap,
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
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.08),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
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
            // اسم المنتج
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
            // السعر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${product.price.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  color: Color(0xFF1A8B35),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            // أزرار المفضلة والسلة في سطر واحد
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر المفضلة
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[400],
                    ),
                    onPressed: onToggleFavorite,
                    tooltip: 'إضافة إلى المفضلة',
                    splashRadius: 22,
                  ),
                  // زر السلة
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton.icon(
                        icon: Icon(
                          isInCart ? Icons.check : Icons.shopping_cart_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          isInCart ? 'في السلة' : 'أضف للسلة',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: isInCart ? null : onAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInCart ? Colors.grey : const Color.fromARGB(255, 92, 128, 118),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                          elevation: 0,
                        ),
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
