import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static String formatCents(int cents, {bool includeSymbol = true}) {
    final double amount = cents / 100.0;
    final formatter = NumberFormat.currency(
      symbol: includeSymbol ? '${AppConstants.currencySymbol} ' : '',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static int parseToCents(String input) {
    if (input.isEmpty) return 0;
    final cleanInput = input.replaceAll(',', '').trim();
    final double value = double.tryParse(cleanInput) ?? 0.0;
    return (value * 100).round();
  }

  static String centsToInputString(int cents) {
    if (cents == 0) return '';
    final double value = cents / 100.0;
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

class DateFormatters {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
