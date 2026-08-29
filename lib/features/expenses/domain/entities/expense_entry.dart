class ExpenseEntryEntity {
  final String id;
  final int amountCents;
  final int categoryId;
  final String? categoryName;
  final DateTime date;
  final String? note;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseEntryEntity({
    required this.id,
    required this.amountCents,
    required this.categoryId,
    this.categoryName,
    required this.date,
    this.note,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  ExpenseEntryEntity copyWith({
    String? id,
    int? amountCents,
    int? categoryId,
    String? categoryName,
    DateTime? date,
    String? note,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntryEntity(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      date: date ?? this.date,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
