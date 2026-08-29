import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/wishlist_item.dart';
import '../providers/wishlist_providers.dart';
import '../widgets/add_purchase_modal.dart';
import '../widgets/add_wishlist_modal.dart';
import '../widgets/mark_purchased_modal.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _wishlistFilterIndex = 0; // 0 = Active, 1 = Purchased

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist & Shopping'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Wishlist'),
            Tab(text: 'Purchase History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWishlistTab(context, isDark),
          _buildPurchaseHistoryTab(context, isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () {
          if (_tabController.index == 0) {
            AddWishlistModal.show(context);
          } else {
            AddPurchaseModal.show(context);
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Add Wish' : 'Log Purchase'),
      ),
    );
  }

  Widget _buildWishlistTab(BuildContext context, bool isDark) {
    final activeItems = ref.watch(activeWishlistItemsProvider);
    final purchasedItems = ref.watch(purchasedWishlistItemsProvider);
    final totalWishlistCents = ref.watch(totalWishlistCentsProvider);
    final displayedItems = _wishlistFilterIndex == 0 ? activeItems : purchasedItems;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Wishlist Value Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.balanceGradientDark : AppColors.balanceGradientLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Wishlist Value', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatCents(totalWishlistCents),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.card_giftcard, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filter Segmented Chips (Active vs Purchased)
          Row(
            children: [
              FilterChip(
                selected: _wishlistFilterIndex == 0,
                label: Text('Active (${activeItems.length})'),
                onSelected: (val) => setState(() => _wishlistFilterIndex = 0),
                selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                checkmarkColor: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: _wishlistFilterIndex == 1,
                label: Text('Purchased (${purchasedItems.length})'),
                onSelected: (val) => setState(() => _wishlistFilterIndex = 1),
                selectedColor: AppColors.successGreen.withOpacity(0.2),
                checkmarkColor: AppColors.successGreen,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Wishlist Items List
          if (displayedItems.isEmpty)
            _buildEmptyState(
              context,
              icon: _wishlistFilterIndex == 0 ? Icons.favorite_border : Icons.shopping_bag_outlined,
              title: _wishlistFilterIndex == 0 ? 'Your wishlist is empty' : 'No purchased wishlist items',
              subtitle: _wishlistFilterIndex == 0
                  ? 'Tap "+ Add Wish" to start tracking things you want to buy.'
                  : 'Items you mark as purchased will appear here.',
              isDark: isDark,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = displayedItems[index];
                return _buildWishlistItemCard(context, item, isDark);
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildWishlistItemCard(BuildContext context, WishlistItemEntity item, bool isDark) {
    Color priorityColor;
    switch (item.priority) {
      case WishlistPriority.high:
        priorityColor = AppColors.expenseRed;
        break;
      case WishlistPriority.medium:
        priorityColor = AppColors.warningAmber;
        break;
      case WishlistPriority.low:
        priorityColor = AppColors.primaryBlue;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                        decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item.priority.name.toUpperCase()} PRIORITY',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: priorityColor),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primaryBlue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatCents(item.priceCents),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                    ),
                  ),
                  if (item.isPurchased)
                    const Text('Purchased', style: TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.notes!,
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!item.isPurchased)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => MarkPurchasedModal.show(context, item),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Mark as Purchased', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
              else
                const SizedBox.shrink(),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => AddWishlistModal.show(context, existingItem: item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed, size: 20),
                    onPressed: () => _confirmDeleteWishlistItem(context, item),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseHistoryTab(BuildContext context, bool isDark) {
    final purchasesAsync = ref.watch(watchAllPurchasesProvider);

    return purchasesAsync.when(
      data: (purchases) {
        if (purchases.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: _buildEmptyState(
              context,
              icon: Icons.shopping_cart_outlined,
              title: 'No purchase history yet',
              subtitle: 'Log direct purchases or mark wishlist items as purchased to build history.',
              isDark: isDark,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: purchases.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final purchase = purchases[index];
            return _buildPurchaseCard(context, purchase, isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading purchases: $err')),
    );
  }

  Widget _buildPurchaseCard(BuildContext context, PurchaseEntity purchase, bool isDark) {
    final isFromWishlist = purchase.linkedWishlistItemId != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isFromWishlist ? AppColors.warningAmber : AppColors.primaryBlue).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFromWishlist ? Icons.card_giftcard : Icons.shopping_bag_outlined,
            color: isFromWishlist ? AppColors.warningAmber : AppColors.primaryBlue,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                purchase.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isFromWishlist)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Wishlist', style: TextStyle(fontSize: 10, color: AppColors.warningAmber, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${DateFormatters.formatDate(purchase.purchaseDate)} • ${purchase.category}${purchase.notes != null ? " • ${purchase.notes}" : ""}',
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyFormatter.formatCents(purchase.amountCents),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.expenseRed),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed, size: 20),
              onPressed: () => _confirmDeletePurchase(context, purchase),
            ),
          ],
        ),
        onTap: () => AddPurchaseModal.show(context, existingPurchase: purchase),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMainDark : AppColors.textMainLight)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        ],
      ),
    );
  }

  void _confirmDeleteWishlistItem(BuildContext context, WishlistItemEntity item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Wishlist Item'),
        content: Text('Are you sure you want to delete "${item.name}" from your wishlist?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(wishlistRepositoryProvider);
              await repo.deleteWishlistItem(item.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePurchase(BuildContext context, PurchaseEntity purchase) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Purchase Record'),
        content: Text(
          'Are you sure you want to delete "${purchase.name}"? This will also remove the linked expense from your total balance.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(wishlistRepositoryProvider);
              await repo.deletePurchase(purchase.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
