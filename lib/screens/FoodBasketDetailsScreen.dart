import 'package:flutter/material.dart';




import 'package:vibe_cart/models/food_basket.dart';

class FoodBasketDetailsScreen extends StatelessWidget {
  final FoodBasket basket;
  const FoodBasketDetailsScreen({required this.basket, super.key});

  // دالة مساعدة لتحويل النص إلى تاريخ ثم صياغته بشكل واضح
 String formatSimpleDate(String dateStr) {
  try {
    final dt = DateTime.parse(dateStr);
  
    return "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  } catch (e) {
    return dateStr; // fallback إذا لم يمكن التحويل
  }
}

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            basket.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة السلة (ملئ العرض)
              basket.image != null && basket.image!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                      child: Image.network(
                        'http://192.168.1.107:8000/storage/${basket.image}',
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.fill,
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 220,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السعر: ${basket.price.toStringAsFixed(2)} ر.ي',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A8B35)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.storefront, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(
                          'اسم السوبرماركت: ${basket.supermarket?.supermarketName ?? ''}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'الوصف: ${basket.description ?? ''}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    // صياغة التاريخ بشكل صحيح
                    Text(
  'الفترة: ${formatSimpleDate(basket.startDate)} إلى ${formatSimpleDate(basket.endDate)}',
  style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
),

                    const SizedBox(height: 100),
                    // الملاحظة
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 206, 59, 22),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color.fromRGBO(168, 2, 2, 1), width: 1),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline, color: Color.fromARGB(168, 255, 255, 255), size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'ملاحظة: لايمكن شراء السلة ولا حجزها، الشراء حضورياً فقط من المحل.',
                              style: TextStyle(
                                color: Color.fromARGB(255, 250, 250, 250),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
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
