class PurchaseEntity {
  final String id;
  final String name;
  final int amountCents;
  final String category;
  final DateTime purchaseDate;
  final String? linkedWishlistItemId;
  final String? linkedExpenseId;
  final String? notes;
  final DateTime createdAt;

  PurchaseEntity({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.category,
    required this.purchaseDate,
    this.linkedWishlistItemId,
    this.linkedExpenseId,
    this.notes,
    required this.createdAt,
  });
}
