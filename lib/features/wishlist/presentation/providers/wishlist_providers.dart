import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return WishlistRepositoryImpl(db);
});

final watchAllWishlistItemsProvider = StreamProvider<List<WishlistItemEntity>>((ref) {
  final repo = ref.watch(wishlistRepositoryProvider);
  return repo.watchAllWishlistItems();
});

final activeWishlistItemsProvider = Provider<List<WishlistItemEntity>>((ref) {
  final asyncValue = ref.watch(watchAllWishlistItemsProvider);
  return asyncValue.maybeWhen(
    data: (list) => list.where((item) => !item.isPurchased).toList(),
    orElse: () => [],
  );
});

final purchasedWishlistItemsProvider = Provider<List<WishlistItemEntity>>((ref) {
  final asyncValue = ref.watch(watchAllWishlistItemsProvider);
  return asyncValue.maybeWhen(
    data: (list) => list.where((item) => item.isPurchased).toList(),
    orElse: () => [],
  );
});

final totalWishlistCentsProvider = Provider<int>((ref) {
  final activeItems = ref.watch(activeWishlistItemsProvider);
  return activeItems.fold<int>(0, (sum, item) => sum + item.priceCents);
});

final watchAllPurchasesProvider = StreamProvider<List<PurchaseEntity>>((ref) {
  final repo = ref.watch(wishlistRepositoryProvider);
  return repo.watchAllPurchases();
});
