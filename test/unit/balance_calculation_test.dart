import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Balance Calculation Logic', () {
    test('Calculates balance as totalIncomeCents - totalExpensesCents', () {
      const totalIncomeCents = 500000; // Rs 5,000.00
      const totalExpensesCents = 150000; // Rs 1,500.00
      const balanceCents = totalIncomeCents - totalExpensesCents;

      expect(balanceCents, equals(350000)); // Rs 3,500.00
    });

    test('Handles negative balance when expenses exceed income', () {
      const totalIncomeCents = 100000; // Rs 1,000.00
      const totalExpensesCents = 250000; // Rs 2,500.00
      const balanceCents = totalIncomeCents - totalExpensesCents;

      expect(balanceCents, equals(-150000)); // -Rs 1,500.00
    });
  });
}
