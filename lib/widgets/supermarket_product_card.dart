import 'package:flutter/material.dart';
import 'package:vibe_cart/models/product.dart';

class SupermarketProductCard extends StatelessWidget {
  final Product product;
  final bool isInCart;
  final bool isFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleFavorite;

  const SupermarketProductCard({
    Key? key,
    required this.product,
    required this.isInCart,
    required this.isFavorite,
    required this.onAddToCart,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String imageUrl = product.image.startsWith('http')
        ? product.image
        : 'http://192.168.1.107:8000/products/${product.image}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                height: 100,
                width: double.infinity,
                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              product.productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${product.price.toStringAsFixed(2)} ر.س',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey),
                  onPressed: onToggleFavorite,
                  tooltip: 'إضافة إلى المفضلة',
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: Text(isInCart ? 'في السلة' : 'أضف للسلة'),
                    onPressed: isInCart ? null : onAddToCart,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
