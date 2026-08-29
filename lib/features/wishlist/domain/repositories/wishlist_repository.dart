import '../entities/purchase.dart';
import '../entities/wishlist_item.dart';

abstract class WishlistRepository {
  // Wishlist
  Stream<List<WishlistItemEntity>> watchAllWishlistItems();
  Future<List<WishlistItemEntity>> getAllWishlistItems();
  Future<String> addWishlistItem({
    required String name,
    required int priceCents,
    required String category,
    required WishlistPriority priority,
    String? notes,
  });
  Future<bool> updateWishlistItem(WishlistItemEntity item);
  Future<int> deleteWishlistItem(String id);

  // Mark as purchased (creates Purchase & linked Expense)
  Future<void> markWishlistItemAsPurchased({
    required String wishlistItemId,
    required int actualPriceCents,
    required DateTime purchaseDate,
  });

  // Purchases
  Stream<List<PurchaseEntity>> watchAllPurchases();
  Future<List<PurchaseEntity>> getAllPurchases();
  Future<String> addPurchase({
    required String name,
    required int amountCents,
    required String category,
    required DateTime purchaseDate,
    String? linkedWishlistItemId,
    String? notes,
  });
  Future<bool> updatePurchase(PurchaseEntity purchase);
  Future<void> deletePurchase(String id);
}
