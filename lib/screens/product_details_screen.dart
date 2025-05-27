import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/models/product.dart';
import 'package:vibe_cart/provider/comment_provider.dart';
import 'package:vibe_cart/provider/favorites_provider.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:vibe_cart/screens/price_comparison_screen.dart';
import 'package:vibe_cart/utils/theme.dart';
import 'package:vibe_cart/widgets/RateProductDialog.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<Product> _similarProducts = [];
  bool _showAllComments = false;
  Set<int> likedCommentIds = {};
  late Future<int> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadCommentsAndReviews();
    fetchSimilarProducts();
  }

  void _loadCommentsAndReviews() {
    Future.microtask(() {
      context.read<CommentProvider>().fetchComments(widget.product.id);
    });
    _reviewsFuture =
        context.read<ProductProvider>().fetchReviewsCount(widget.product.id);
  }

  String resolveImageUrl(String image) {
    if (image.startsWith('http')) {
      return image;
    } else if (image.endsWith('.jpg') ||
        image.endsWith('.jpeg') ||
        image.endsWith('.png')) {
      return 'http://192.168.1.107:8000/products/$image';
    } else {
      return '';
    }
  }

  void fetchSimilarProducts() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final products = await provider.fetchSimilarProducts(widget.product.id);
    setState(() {
      _similarProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final favProv = context.watch<FavoritesProvider>();
    final isFavorited = favProv.favorites
        .any((fav) => fav.type == 'product' && fav.productId == product.id);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المنتج'),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إضافة المنتج إلى السلة')),
                );
              },
            ),
            IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : null,
              ),
              onPressed: () async {
                if (isFavorited) {
                  await favProv.removeFavorite(
                      type: 'product', favoritableId: product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('تمت إزالة المنتج من المفضلة')),
                  );
                } else {
                  await favProv.addFavorite(
                      type: 'product', favoritableId: product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة المنتج إلى المفضلة')),
                  );
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              SizedBox(
                width: double.infinity,
                height: 250,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: resolveImageUrl(product.image).isNotEmpty
                      ? Image.network(
                          resolveImageUrl(product.image),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 90,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 90,
                          ),
                        ),
                ),
              ),

              // بيانات المنتج
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.supermarketName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          product.supermarketName,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    Text(
                      product.productName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // تقييمات المنتج
                    FutureBuilder<int>(
                      future: _reviewsFuture,
                      builder: (c, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child:
                                Text('جاري تحميل التقييمات...', style: TextStyle(fontSize: 14)),
                          );
                        }
                        if (snap.hasError) {
                          return const Text('خطأ في جلب التقييمات');
                        }
                        final count = snap.data ?? 0;
                        return Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 22),
                            const SizedBox(width: 4),
                            Text('$count تقييم', style: const TextStyle(fontSize: 15)),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      RateProductDialog(productId: product.id),
                                );
                              },
                              icon: const Icon(Icons.star_half),
                              label: const Text('قيّم المنتج'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} ر.ي',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent),
                        ),
                        const SizedBox(width: 10),
                        if (product.isOffer)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'عرض خاص',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PriceComparisonScreen(
                                barcode: product.barcode),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.compare_arrows,
                                color: Colors.blue, size: 18),
                            SizedBox(width: 4),
                            Text('مقارنة السعر بين المراكز',
                                style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text('الوصف',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(product.description,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87)),

                    const SizedBox(height: 24),
                    const Text('التعليقات',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // قائمة التعليقات
                    Consumer<CommentProvider>(builder: (c, prov, _) {
                      if (prov.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (prov.comments.isEmpty) {
                        return const Center(child: Text('لا توجد تعليقات بعد'));
                      }
                      final toShow = _showAllComments
                          ? prov.comments
                          : prov.comments.take(4).toList();

                      return Column(
                        children: [
                          ...toShow.map((comm) {
                            return ListTile(
                              title: Text(comm.body),
                              subtitle:
                                  Text(comm.userName ?? 'مستخدم مجهول'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.thumb_up,
                                      color: likedCommentIds
                                              .contains(comm.id)
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    onPressed: () async {
                                    
                                      final newCount =
                                          await prov.fetchLikesCount(comm.id);
                                      setState(() {
                                        comm.likesCount = newCount;
                                        if (likedCommentIds
                                            .contains(comm.id)) {
                                          likedCommentIds.remove(comm.id);
                                        } else {
                                          likedCommentIds.add(comm.id);
                                        }
                                      });
                                    },
                                  ),
                                  Text('${comm.likesCount}'),
                                ],
                              ),
                            );
                          }),
                          if (!_showAllComments && prov.comments.length > 4)
                            TextButton(
                              onPressed: () => setState(() {
                                _showAllComments = true;
                              }),
                              child: const Text('عرض المزيد'),
                            ),
                          if (_showAllComments && prov.comments.length > 4)
                            TextButton(
                              onPressed: () => setState(() {
                                _showAllComments = false;
                              }),
                              child: const Text('عرض أقل'),
                            ),
                        ],
                      );
                    }),

                    // إضافة تعليق جديد
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: 'أضف تعليقًا...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              final text = _commentController.text.trim();
                              if (text.isNotEmpty) {
                                context
                                    .read<CommentProvider>()
                                    .addComment(widget.product.id, text);
                                _commentController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('تم إرسال التعليق')),
                                );
                                setState(() => _showAllComments = false);
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // منتجات مشابهة
                    if (_similarProducts.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('منتجات مشابهة',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _similarProducts.length,
                          itemBuilder: (_, idx) {
                            final p = _similarProducts[idx];
                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ProductDetailsScreen(product: p)),
                                  );
                                },
                                child: SizedBox(
                                  width: 140,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(10)),
                                          child: resolveImageUrl(p.image)
                                                  .isNotEmpty
                                              ? Image.network(
                                                  resolveImageUrl(p.image),
                                                  fit: BoxFit.contain,
                                                  errorBuilder:
                                                      (_, __, ___) => Container(
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
                                      Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Text(
                                          p.productName,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text('${p.price} ر.ي',
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
