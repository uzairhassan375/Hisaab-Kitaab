import 'package:intl/intl.dart';

class CurrencyFormatter {
  static NumberFormat get currencyFormat {
    return NumberFormat.currency(symbol: 'PKR ', decimalDigits: 2);
  }

  static String format(double amount) {
    return currencyFormat.format(amount);
  }

  static String formatCompact(double amount) {
    return 'PKR ${NumberFormat('#,##0.00').format(amount)}';
  }
}

