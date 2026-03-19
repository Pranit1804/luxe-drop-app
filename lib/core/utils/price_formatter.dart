import 'package:intl/intl.dart';

class PriceFormatter {
  PriceFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _formatterWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String format(double price) => _formatter.format(price);

  static String formatWithDecimals(double price) =>
      _formatterWithDecimals.format(price);

  static String formatChange(double change) {
    final prefix = change >= 0 ? '+' : '';
    return '$prefix${_formatter.format(change)}';
  }
}
