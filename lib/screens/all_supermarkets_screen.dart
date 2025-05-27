import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_cart/provider/supermarket_provider.dart';
import 'package:vibe_cart/screens/center_products_screen.dart';

class AllSupermarketsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final marketProv = context.watch<SuperMarketProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('جميع السوبرماركتات')),
        body: marketProv.isLoading
            ? const Center(child: CircularProgressIndicator())
            : marketProv.supermarkets.isEmpty
                ? const Center(child: Text('لا توجد سوبرماركتات متاحة'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.70,
                    ),
                    itemCount: marketProv.supermarkets.length,
                    itemBuilder: (ctx, i) {
                      final m = marketProv.supermarkets[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SupermarketMainScreen(supermarket: m),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                backgroundImage: m.imageUrl != null && m.imageUrl.isNotEmpty
                                    ? NetworkImage(m.imageUrl)
                                    : null,
                                radius: 28,
                                child: (m.imageUrl == null || m.imageUrl.isEmpty)
                                    ? const Icon(Icons.store, size: 26, color: Colors.blueGrey)
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                m.supermarketName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF234D59),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.location ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
