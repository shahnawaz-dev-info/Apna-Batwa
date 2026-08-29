import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/local/app_database.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  WishlistRepositoryImpl(this._db);

  Future<int> _getOrCreateCategoryId(String categoryName) async {
    final allCats = await _db.getAllCategories();
    final match = allCats.where((c) => c.name.toLowerCase() == categoryName.trim().toLowerCase());
    if (match.isNotEmpty) return match.first.id;
    return await _db.insertCategory(
      CategoriesCompanion.insert(
        name: categoryName.trim(),
        type: 'expense',
        isDefault: const Value(false),
      ),
    );
  }

  // Wishlist Items
  @override
  Stream<List<WishlistItemEntity>> watchAllWishlistItems() {
    return _db.watchAllWishlistItems().map(
          (rows) => rows
              .map(
                (r) => WishlistItemEntity(
                  id: r.id,
                  name: r.name,
                  priceCents: r.priceCents,
                  category: r.category,
                  priority: WishlistItemEntity.priorityFromString(r.priority),
                  notes: r.notes,
                  isPurchased: r.isPurchased,
                  createdAt: r.createdAt,
                  purchasedAt: r.purchasedAt,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<List<WishlistItemEntity>> getAllWishlistItems() async {
    final rows = await _db.getAllWishlistItems();
    return rows
        .map(
          (r) => WishlistItemEntity(
            id: r.id,
            name: r.name,
            priceCents: r.priceCents,
            category: r.category,
            priority: WishlistItemEntity.priorityFromString(r.priority),
            notes: r.notes,
            isPurchased: r.isPurchased,
            createdAt: r.createdAt,
            purchasedAt: r.purchasedAt,
          ),
        )
        .toList();
  }

  @override
  Future<String> addWishlistItem({
    required String name,
    required int priceCents,
    required String category,
    required WishlistPriority priority,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.insertWishlistItem(
      WishlistItemsCompanion.insert(
        id: id,
        name: name.trim(),
        priceCents: priceCents,
        category: category.trim(),
        priority: WishlistItemEntity.priorityToString(priority),
        notes: Value(notes?.trim()),
        createdAt: now,
      ),
    );
    return id;
  }

  @override
  Future<bool> updateWishlistItem(WishlistItemEntity item) async {
    return await _db.updateWishlistItem(
      WishlistItemsCompanion(
        id: Value(item.id),
        name: Value(item.name.trim()),
        priceCents: Value(item.priceCents),
        category: Value(item.category.trim()),
        priority: Value(WishlistItemEntity.priorityToString(item.priority)),
        notes: Value(item.notes?.trim()),
        isPurchased: Value(item.isPurchased),
        createdAt: Value(item.createdAt),
        purchasedAt: Value(item.purchasedAt),
      ),
    );
  }

  @override
  Future<int> deleteWishlistItem(String id) async {
    return await _db.deleteWishlistItem(id);
  }

  @override
  Future<void> markWishlistItemAsPurchased({
    required String wishlistItemId,
    required int actualPriceCents,
    required DateTime purchaseDate,
  }) async {
    final items = await _db.getAllWishlistItems();
    final match = items.where((i) => i.id == wishlistItemId);
    if (match.isEmpty) return;

    final item = match.first;
    final now = DateTime.now();

    // 1. Mark wishlist item isPurchased = true
    await _db.updateWishlistItem(
      WishlistItemsCompanion(
        id: Value(item.id),
        name: Value(item.name),
        priceCents: Value(item.priceCents),
        category: Value(item.category),
        priority: Value(item.priority),
        notes: Value(item.notes),
        isPurchased: const Value(true),
        createdAt: Value(item.createdAt),
        purchasedAt: Value(purchaseDate),
      ),
    );

    // 2. Create linked Expense entry
    final expenseId = _uuid.v4();
    final catId = await _getOrCreateCategoryId(item.category);

    await _db.insertExpenseEntry(
      ExpenseEntriesCompanion.insert(
        id: expenseId,
        amountCents: actualPriceCents,
        categoryId: catId,
        date: purchaseDate,
        note: Value('Wishlist purchase: ${item.name}'),
        paymentMethod: const Value('Wishlist'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // 3. Create linked Purchase entry
    final purchaseId = _uuid.v4();
    await _db.insertPurchase(
      PurchasesCompanion.insert(
        id: purchaseId,
        name: item.name,
        amountCents: actualPriceCents,
        category: item.category,
        purchaseDate: purchaseDate,
        linkedWishlistItemId: Value(item.id),
        linkedExpenseId: Value(expenseId),
        notes: Value(item.notes),
        createdAt: now,
      ),
    );
  }

  // Purchases
  @override
  Stream<List<PurchaseEntity>> watchAllPurchases() {
    return _db.watchAllPurchases().map(
          (rows) => rows
              .map(
                (r) => PurchaseEntity(
                  id: r.id,
                  name: r.name,
                  amountCents: r.amountCents,
                  category: r.category,
                  purchaseDate: r.purchaseDate,
                  linkedWishlistItemId: r.linkedWishlistItemId,
                  linkedExpenseId: r.linkedExpenseId,
                  notes: r.notes,
                  createdAt: r.createdAt,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<List<PurchaseEntity>> getAllPurchases() async {
    final rows = await _db.getAllPurchases();
    return rows
        .map(
          (r) => PurchaseEntity(
            id: r.id,
            name: r.name,
            amountCents: r.amountCents,
            category: r.category,
            purchaseDate: r.purchaseDate,
            linkedWishlistItemId: r.linkedWishlistItemId,
            linkedExpenseId: r.linkedExpenseId,
            notes: r.notes,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<String> addPurchase({
    required String name,
    required int amountCents,
    required String category,
    required DateTime purchaseDate,
    String? linkedWishlistItemId,
    String? notes,
  }) async {
    final purchaseId = _uuid.v4();
    final expenseId = _uuid.v4();
    final now = DateTime.now();

    // 1. Create linked Expense entry
    final catId = await _getOrCreateCategoryId(category);
    await _db.insertExpenseEntry(
      ExpenseEntriesCompanion.insert(
        id: expenseId,
        amountCents: amountCents,
        categoryId: catId,
        date: purchaseDate,
        note: Value('Direct purchase: ${name.trim()}'),
        paymentMethod: const Value('Direct Purchase'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // 2. Create Purchase record
    await _db.insertPurchase(
      PurchasesCompanion.insert(
        id: purchaseId,
        name: name.trim(),
        amountCents: amountCents,
        category: category.trim(),
        purchaseDate: purchaseDate,
        linkedWishlistItemId: Value(linkedWishlistItemId),
        linkedExpenseId: Value(expenseId),
        notes: Value(notes?.trim()),
        createdAt: now,
      ),
    );

    return purchaseId;
  }

  @override
  Future<bool> updatePurchase(PurchaseEntity purchase) async {
    final now = DateTime.now();

    // Update linked expense if exists
    if (purchase.linkedExpenseId != null) {
      final catId = await _getOrCreateCategoryId(purchase.category);
      await _db.updateExpenseEntry(
        ExpenseEntriesCompanion(
          id: Value(purchase.linkedExpenseId!),
          amountCents: Value(purchase.amountCents),
          categoryId: Value(catId),
          date: Value(purchase.purchaseDate),
          note: Value('Purchase: ${purchase.name.trim()}'),
          updatedAt: Value(now),
        ),
      );
    }

    return await _db.updatePurchase(
      PurchasesCompanion(
        id: Value(purchase.id),
        name: Value(purchase.name.trim()),
        amountCents: Value(purchase.amountCents),
        category: Value(purchase.category.trim()),
        purchaseDate: Value(purchase.purchaseDate),
        linkedWishlistItemId: Value(purchase.linkedWishlistItemId),
        linkedExpenseId: Value(purchase.linkedExpenseId),
        notes: Value(purchase.notes?.trim()),
        createdAt: Value(purchase.createdAt),
      ),
    );
  }

  @override
  Future<void> deletePurchase(String id) async {
    final purchases = await _db.getAllPurchases();
    final match = purchases.where((p) => p.id == id);
    if (match.isNotEmpty) {
      final purchase = match.first;
      if (purchase.linkedExpenseId != null) {
        await _db.deleteExpenseEntry(purchase.linkedExpenseId!);
      }
    }
    await _db.deletePurchase(id);
  }
}
