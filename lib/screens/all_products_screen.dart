import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/widgets/product_item.dart';
import 'package:vibe_cart/screens/price_comparison_screen.dart';

class AllLatestProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prodProv = context.watch<ProductProvider>();
    final all = prodProv.products;
    final uniqueMap = <String, dynamic>{};
    for (var p in all) {
      final key = p.barcode.isNotEmpty ? p.barcode : p.productName;
      uniqueMap.putIfAbsent(key, () => p);
    }
    final products = uniqueMap.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('جميع المنتجات')),
      body: prodProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('لا توجد منتجات'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) {
                    final product = products[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PriceComparisonScreen(barcode: product.barcode),
                          ),
                        );
                      },
                      child: ProductItem(product: product),
                    );
                  },
                ),
    );
  }
}
