import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vibe_cart/models/price_comparison.dart';
import 'package:vibe_cart/models/product.dart'; // إضافة استيراد نموذج المنتج
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/provider/cart_provider.dart';
import 'package:vibe_cart/utils/theme.dart';
import 'package:vibe_cart/screens/product_details_screen.dart'; // إضافة استيراد صفحة تفاصيل المنتج

class PriceComparisonScreen extends StatefulWidget {
  final String barcode;

  const PriceComparisonScreen({
    Key? key,
    required this.barcode,
  }) : super(key: key);

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  bool _isLoading = true;
  String _error = '';
  PriceComparison? _comparison;
  Map<int, bool> _addingToCart = {};

  @override
  void initState() {
    super.initState();
    _loadComparison();
  }

  Future<void> _loadComparison() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final comp = await context
          .read<ProductProvider>()
          .getComparisonByBarcode(widget.barcode);
      setState(() {
        _comparison = comp;
        _isLoading = false;
        _addingToCart = {
          for (var offer in comp.offers) offer.supermarketId: false
        };
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // إضافة دالة لإضافة المنتج إلى السلة
// داخل PriceComparisonScreen
// داخل PriceComparisonScreen
Future<void> _addToCart(PriceOffer offer) async {
  setState(() => _addingToCart[offer.supermarketId] = true);

  try {
    // 1) جلب قائمة المنتجات لهذا السوبرماركت
    final productProvider = context.read<ProductProvider>();
    final products = await productProvider.getProductsBySupermarket(offer.supermarketId);

    // 2) إيجاد المنتج الذي يطابق barcode واسم المنتج
    final product = products.firstWhere(
      (p) =>
          p.barcode == _comparison!.barcode &&
          p.productName == _comparison!.productName,
      orElse: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هذا المنتج غير متوفر في هذا السوبرماركت'),
            backgroundColor: Colors.orange,
          ),
        );
        throw StateError('Product not found in supermarket ${offer.supermarketId}');
      },
    );

    // 3) إرسال طلب الإضافة بمعرّف المنتج الصحيح
    await context.read<CartProvider>().add(
      product.id,
      offer.supermarketId,
      1,
    );

    // 4) إظهار رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة "${product.productName}" إلى السلة'),
        backgroundColor: Colors.green,
      ),
    );

    // 5) إعادة تحميل السلة بشكل منفصل، وأي فشل هنا لا يؤثر على نجاح الإضافة
    try {
      await context.read<CartProvider>().loadCart();
    } catch (_) {
      debugPrint('تمت إضافة العنصر ولكن فشل تحميل محتوى السلة');
    }

  } catch (e) {
    // هذا catch يصيد فقط الأخطاء الحقيقية من جلب المنتج أو الإضافة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('فشل إضافة المنتج: ${e.toString().replaceAll("Exception: ", "")}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _addingToCart[offer.supermarketId] = false);
    }
  }
}




  // إضافة دالة للانتقال إلى صفحة تفاصيل المنتج
  void _navigateToProductDetails(PriceOffer offer) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // جلب تفاصيل المنتج من قاعدة البيانات باستخدام productProvider
      final productProvider = context.read<ProductProvider>();
      final List<Product> products = await productProvider.getProductsBySupermarket(offer.supermarketId);
      
      // البحث عن المنتج المطابق للباركود
      final product = products.firstWhere(
        (p) => p.barcode == _comparison!.barcode,
        orElse: () => Product(
          id: int.parse(_comparison!.barcode),
          productName: _comparison!.productName,
          barcode: _comparison!.barcode,
          price: offer.price,
          categoryId: 0, // قيمة افتراضية
          description: '',
          image: offer.imageUrl,
          supermarketId: offer.supermarketId,
        ),
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // الانتقال إلى صفحة تفاصيل المنتج
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تحميل تفاصيل المنتج: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مقارنة الأسعار'),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              )
            : _error.isNotEmpty
                ? _buildError()
                : (_comparison == null || _comparison!.offers.isEmpty)
                    ? const Center(
                        child: Text('لا توجد عروض للمقارنة'),
                      )
                    : _buildComparison(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ: $_error',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadComparison,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparison() {
    final comp = _comparison!;
    final bestPrice = comp.minPrice;

    return Column(
      children: [
        // عنوان المنتج
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                comp.productName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'أسعار المنتج في المراكز التجارية المختلفة',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // بطاقة أفضل سعر
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أفضل سعر',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ريال ${bestPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'وفّرت ${comp.saving.toStringAsFixed(0)} ريال',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // قائمة العروض في السوبرماركتات المختلفة
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: comp.offers.length,
            itemBuilder: (context, index) {
              final offer = comp.offers[index];
              final isBest = offer.price == bestPrice;
              final difference = offer.price - bestPrice;
              final isAddingToCart = _addingToCart[offer.supermarketId] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isBest
                      ? const BorderSide(color: Colors.green, width: 1.5)
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // صورة المركز التجاري
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: offer.imageUrl.isNotEmpty
                            ? Image.network(
                                offer.imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.store,
                                  color: AppColors.accent,
                                  size: 40,
                                ),
                              )
                            : const Icon(
                                Icons.store,
                                size: 40,
                                color: AppColors.accent,
                              ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // معلومات العرض
                      Expanded(
                        child: InkWell(
                          onTap: () => _navigateToProductDetails(offer),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer.supermarketName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent, // تغيير لون النص ليبدو كرابط
                                  decoration: TextDecoration.underline, // إضافة خط تحت النص
                                ),
                              ),
                              if (!isBest)
                                Text(
                                  'أغلى بـ ${difference.toStringAsFixed(0)} ريال',
                                  style: const TextStyle(
                                    color: Colors.red, 
                                    fontSize: 12
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      // السعر
                      Text(
                        '${offer.price.toStringAsFixed(0)} ر.س',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBest ? Colors.green : AppColors.accent,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // زر إضافة إلى السلة
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: isAddingToCart
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.accent,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.add_shopping_cart,
                                  color: AppColors.accent,
                                ),
                          onPressed: isAddingToCart
                              ? null
                              : () => _addToCart(offer),
                          tooltip: 'إضافة إلى السلة',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
