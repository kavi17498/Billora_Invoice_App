import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _currencyKey = 'selected_currency';
  static const String _defaultCurrency = 'USD';

  // List of supported currencies
  static const Map<String, Currency> supportedCurrencies = {
    'USD': Currency(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      countryFlag: '🇺🇸',
    ),
    'LKR': Currency(
      code: 'LKR',
      symbol: 'Rs.',
      name: 'Sri Lankan Rupee',
      countryFlag: '🇱🇰',
    ),
    'EUR': Currency(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      countryFlag: '🇪🇺',
    ),
    'GBP': Currency(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      countryFlag: '🇬🇧',
    ),
    'JPY': Currency(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      countryFlag: '🇯🇵',
    ),
    'INR': Currency(
      code: 'INR',
      symbol: '₹',
      name: 'Indian Rupee',
      countryFlag: '🇮🇳',
    ),
    'AUD': Currency(
      code: 'AUD',
      symbol: 'A\$',
      name: 'Australian Dollar',
      countryFlag: '🇦🇺',
    ),
    'CAD': Currency(
      code: 'CAD',
      symbol: 'C\$',
      name: 'Canadian Dollar',
      countryFlag: '🇨🇦',
    ),
    'SGD': Currency(
      code: 'SGD',
      symbol: 'S\$',
      name: 'Singapore Dollar',
      countryFlag: '🇸🇬',
    ),
    'MYR': Currency(
      code: 'MYR',
      symbol: 'RM',
      name: 'Malaysian Ringgit',
      countryFlag: '🇲🇾',
    ),
  };

  // Get current selected currency
  static Future<Currency> getCurrentCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyCode = prefs.getString(_currencyKey) ?? _defaultCurrency;
    return supportedCurrencies[currencyCode] ??
        supportedCurrencies[_defaultCurrency]!;
  }

  // Set selected currency
  static Future<void> setCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currencyCode);
  }

  // Format amount with currency
  static String formatAmount(double amount, Currency currency) {
    return '${currency.symbol} ${amount.toStringAsFixed(2)}';
  }

  // Format amount with current currency
  static Future<String> formatAmountWithCurrentCurrency(double amount) async {
    final currency = await getCurrentCurrency();
    return formatAmount(amount, currency);
  }

  // Get currency symbol only
  static Future<String> getCurrentCurrencySymbol() async {
    final currency = await getCurrentCurrency();
    return currency.symbol;
  }

  // Get currency code only
  static Future<String> getCurrentCurrencyCode() async {
    final currency = await getCurrentCurrency();
    return currency.code;
  }
}

class Currency {
  final String code;
  final String symbol;
  final String name;
  final String countryFlag;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.countryFlag,
  });

  @override
  String toString() => '$countryFlag $name ($symbol)';
}
