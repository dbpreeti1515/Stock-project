import 'package:intl/intl.dart';

class StockFormatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static String currency(double value) => _currencyFormatter.format(value);

  static String change(double value) {
    final prefix = value >= 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }
}
