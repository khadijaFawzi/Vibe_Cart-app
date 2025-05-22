// lib/screens/category_products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/models/category_model.dart';
import 'package:vibe_cart/models/product.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/screens/price_comparison_screen.dart';
import 'package:vibe_cart/widgets/product_item.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Category category;

  const CategoryProductsScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final prodProv = context.read<ProductProvider>();
      final products = await prodProv.fetchProductsByCategory(widget.category.id);

      // إزالة التكرار حسب الباركود أو الاسم
      final map = <String, Product>{};
      for (var p in products) {
        final key = p.barcode.isNotEmpty ? p.barcode : p.productName;
        if (!map.containsKey(key)) {
          map[key] = p;
        }
      }
      _products = map.values.toList();

      if (_products.isEmpty) {
        _error = 'لا توجد منتجات في هذه الفئة حالياً.';
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء جلب المنتجات: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('منتجات فئة "${widget.category.categoryName}"'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
                ? Center(child: Text(_error))
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (ctx, i) {
                        final p = _products[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PriceComparisonScreen(barcode: p.barcode),
                              ),
                            );
                          },
                          child: ProductItem(product: p),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
