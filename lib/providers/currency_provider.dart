import 'package:flutter/foundation.dart';

enum AppCurrency { dzd, eur, usd }

class CurrencyProvider extends ChangeNotifier {
  AppCurrency _currency = AppCurrency.dzd;

  static const double eurToDzd = 279.0;
  static const double usdToDzd = 230.0;
  static const double eurToUsd = 1.16;

  AppCurrency get currency => _currency;

  void setCurrency(AppCurrency c) {
    if (_currency == c) return;
    _currency = c;
    notifyListeners();
  }

  String formatPrice(double priceInDzd) => switch (_currency) {
    AppCurrency.dzd => '${priceInDzd.toStringAsFixed(0)} DA',
    AppCurrency.eur => '€${(priceInDzd / eurToDzd).toStringAsFixed(0)}',
    AppCurrency.usd => '\$${(priceInDzd / usdToDzd).toStringAsFixed(0)}',
  };
}
