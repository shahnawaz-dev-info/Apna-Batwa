enum RecurringFrequency { daily, weekly, monthly }

extension RecurringFrequencyExtension on RecurringFrequency {
  String get name {
    switch (this) {
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.monthly:
        return 'Monthly';
    }
  }

  static RecurringFrequency fromString(String val) {
    switch (val.toLowerCase()) {
      case 'daily':
        return RecurringFrequency.daily;
      case 'weekly':
        return RecurringFrequency.weekly;
      case 'monthly':
      default:
        return RecurringFrequency.monthly;
    }
  }
}

class RecurringTransactionEntity {
  final String id;
  final String type; // 'income' or 'expense'
  final String name;
  final int amountCents;
  final String category;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime nextDueDate;
  final bool isActive;
  final DateTime? lastGeneratedDate;
  final DateTime createdAt;

  const RecurringTransactionEntity({
    required this.id,
    required this.type,
    required this.name,
    required this.amountCents,
    required this.category,
    required this.frequency,
    required this.startDate,
    required this.nextDueDate,
    this.isActive = true,
    this.lastGeneratedDate,
    required this.createdAt,
  });

  bool get isIncome => type.toLowerCase() == 'income';
  bool get isExpense => type.toLowerCase() == 'expense';

  RecurringTransactionEntity copyWith({
    String? id,
    String? type,
    String? name,
    int? amountCents,
    String? category,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? nextDueDate,
    bool? isActive,
    DateTime? lastGeneratedDate,
    DateTime? createdAt,
  }) {
    return RecurringTransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      amountCents: amountCents ?? this.amountCents,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
