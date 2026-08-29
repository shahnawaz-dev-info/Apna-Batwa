enum WishlistPriority { high, medium, low }

class WishlistItemEntity {
  final String id;
  final String name;
  final int priceCents;
  final String category;
  final WishlistPriority priority;
  final String? notes;
  final bool isPurchased;
  final DateTime createdAt;
  final DateTime? purchasedAt;

  WishlistItemEntity({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.category,
    required this.priority,
    this.notes,
    this.isPurchased = false,
    required this.createdAt,
    this.purchasedAt,
  });

  static WishlistPriority priorityFromString(String val) {
    switch (val.toLowerCase()) {
      case 'high':
        return WishlistPriority.high;
      case 'medium':
        return WishlistPriority.medium;
      case 'low':
      default:
        return WishlistPriority.low;
    }
  }

  static String priorityToString(WishlistPriority priority) {
    switch (priority) {
      case WishlistPriority.high:
        return 'high';
      case WishlistPriority.medium:
        return 'medium';
      case WishlistPriority.low:
        return 'low';
    }
  }
}
