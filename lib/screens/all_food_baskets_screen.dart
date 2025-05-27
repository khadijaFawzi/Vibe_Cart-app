import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/provider/food_basket_provider.dart';
import 'package:vibe_cart/screens/FoodBasketDetailsScreen.dart';

class AllFoodBasketsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final basketProv = context.watch<FoodBasketProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('جميع السلات الغذائية')),
        body: basketProv.isLoading
            ? const Center(child: CircularProgressIndicator())
            : basketProv.foodBaskets.isEmpty
                ? const Center(child: Text('لا توجد سلات غذائية متاحة'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemCount: basketProv.foodBaskets.length,
                    itemBuilder: (ctx, i) {
                      final basket = basketProv.foodBaskets[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FoodBasketDetailsScreen(basket: basket),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: basket.image != null && basket.image!.isNotEmpty
                                    ? Image.network(
                                        'http://192.168.1.107:8000/storage/${basket.image}',
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      basket.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'السعر: ${basket.price.toStringAsFixed(2)} ر.ي',
                                      style: const TextStyle(
                                        color: Color(0xFF1A8B35),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.storefront, size: 18, color: Color(0xFF234D59)),
                                        const SizedBox(width: 4),
                                        Text(
                                          basket.supermarket?.supermarketName ?? '',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
