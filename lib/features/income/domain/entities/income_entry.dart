class IncomeEntryEntity {
  final String id;
  final int amountCents;
  final String source; // e.g. Home, Pocket Money, Salary, Internship, Freelancing, Scholarship, Gift, Other
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IncomeEntryEntity({
    required this.id,
    required this.amountCents,
    required this.source,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  IncomeEntryEntity copyWith({
    String? id,
    int? amountCents,
    String? source,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncomeEntryEntity(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      source: source ?? this.source,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
