import 'package:flutter/material.dart';
import 'package:vibe_cart/api/api_service.dart';
import '../models/offer.dart';


class OffersProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

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
}
