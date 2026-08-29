import 'package:flutter_test/flutter_test.dart';
import 'package:apnabatwa/core/utils/formatters.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formatCents formats 15000 cents correctly to Rs. 150.00', () {
      final formatted = CurrencyFormatter.formatCents(15000);
      expect(formatted.contains('150.00'), isTrue);
    });

    test('parseToCents parses string decimal inputs correctly', () {
      expect(CurrencyFormatter.parseToCents('150'), equals(15000));
      expect(CurrencyFormatter.parseToCents('150.50'), equals(15050));
      expect(CurrencyFormatter.parseToCents('0'), equals(0));
      expect(CurrencyFormatter.parseToCents(''), equals(0));
    });

    test('centsToInputString converts cents back to standard string', () {
      expect(CurrencyFormatter.centsToInputString(15000), equals('150'));
      expect(CurrencyFormatter.centsToInputString(15050), equals('150.50'));
      expect(CurrencyFormatter.centsToInputString(0), equals(''));
    });
  });
}
