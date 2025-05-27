import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/provider/product_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateProductDialog extends StatefulWidget {
  final int productId;

  const RateProductDialog({Key? key, required this.productId}) : super(key: key);

  @override
  State<RateProductDialog> createState() => _RateProductDialogState();
}

class _RateProductDialogState extends State<RateProductDialog> {
  double _rating = 3;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('قيّم المنتج'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          if (_loading) const Padding(
            padding: EdgeInsets.only(top: 12),
            child: CircularProgressIndicator(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
ElevatedButton(
  onPressed: _loading
      ? null
      : () async {
          setState(() => _loading = true);
          try {
            // جلب التوكن من SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('token') ?? '';
print('TOKEN IS: $token');

            if (token.isEmpty) {
              throw Exception('لم يتم العثور على رمز الدخول. الرجاء تسجيل الدخول مجددًا.');
            }

            await Provider.of<ProductProvider>(context, listen: false)
                .rateProduct(widget.productId, _rating.toInt(), token);

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إرسال تقييمك!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل إرسال التقييم: $e')),
            );
          } finally {
            setState(() => _loading = false);
          }
        },
  child: const Text('إرسال'),
),

      ],
    );
  }
}
