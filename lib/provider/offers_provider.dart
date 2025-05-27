import 'package:flutter/material.dart';
import 'package:vibe_cart/api/api_service.dart';
import '../models/offer.dart';
import 'package:vibe_cart/api/api_service.dart';

class OffersProvider extends ChangeNotifier {
 

  List<Offer> _offers = [];
  bool _isLoadingOffers = false;
  String _offersError = '';

  List<Offer> get offers => _offers;
  bool get isLoadingOffers => _isLoadingOffers;
  String get offersError => _offersError;

  Future<void> loadOffers() async {
    _isLoadingOffers = true;
    _offersError = '';
    notifyListeners();
    try {
      _offers = await ApiService().getOffers();
    } catch (e) {
      _offersError = e.toString();
    } finally {
      _isLoadingOffers = false;
      notifyListeners();
    }
  }

  Future<List<Offer>> loadOffersBySupermarket(int supermarketId) async {
  _isLoadingOffers = true;
  _offersError = '';
  final ApiService _api = ApiService();

  notifyListeners();
  try {
    final offers = await _api.getOffersBySupermarket(supermarketId);
    _isLoadingOffers = false;
    notifyListeners();
    return offers;
  } catch (e) {
    _isLoadingOffers = false;
    _offersError = 'فشل في جلب العروض: $e';
    notifyListeners();
    return [];
  }
}

}
