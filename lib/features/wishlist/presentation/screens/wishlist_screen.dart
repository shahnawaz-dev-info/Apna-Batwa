import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_translations.dart';
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
  String _wishlistSearchQuery = '';
  String _purchaseSearchQuery = '';

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
    final tr = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('wishlist_title')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(text: tr('wishlist_tab_wishlist')),
            Tab(text: tr('wishlist_tab_purchases')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWishlistTab(context, isDark, tr),
          _buildPurchaseHistoryTab(context, isDark, tr),
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
        label: Text(_tabController.index == 0 ? tr('wishlist_add_wish') : tr('wishlist_log_purchase')),
      ),
    );
  }

  Widget _buildWishlistTab(BuildContext context, bool isDark, String Function(String) tr) {
    final activeItems = ref.watch(activeWishlistItemsProvider);
    final purchasedItems = ref.watch(purchasedWishlistItemsProvider);
    final totalWishlistCents = ref.watch(totalWishlistCentsProvider);
    final rawDisplayedItems = _wishlistFilterIndex == 0 ? activeItems : purchasedItems;

    final displayedItems = rawDisplayedItems.where((item) {
      if (_wishlistSearchQuery.isEmpty) return true;
      final q = _wishlistSearchQuery.toLowerCase();
      return item.name.toLowerCase().contains(q) || item.category.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            onChanged: (val) => setState(() => _wishlistSearchQuery = val),
            decoration: InputDecoration(
              hintText: tr('wishlist_search_hint'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _wishlistSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _wishlistSearchQuery = ''),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
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
                    Text(tr('wishlist_total_value'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                label: Text('${tr('wishlist_tab_active')} (${activeItems.length})'),
                onSelected: (val) => setState(() => _wishlistFilterIndex = 0),
                selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: _wishlistFilterIndex == 1,
                label: Text('${tr('wishlist_tab_purchased')} (${purchasedItems.length})'),
                onSelected: (val) => setState(() => _wishlistFilterIndex = 1),
                selectedColor: AppColors.successGreen.withValues(alpha: 0.2),
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
              title: _wishlistFilterIndex == 0 ? tr('wishlist_empty_active_title') : tr('wishlist_empty_purchased_title'),
              subtitle: _wishlistFilterIndex == 0 ? tr('wishlist_empty_active_sub') : tr('wishlist_empty_purchased_sub'),
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
                return _buildWishlistItemCard(context, item, isDark, tr);
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildWishlistItemCard(BuildContext context, WishlistItemEntity item, bool isDark, String Function(String) tr) {
    Color priorityColor;
    String priorityText;
    switch (item.priority) {
      case WishlistPriority.high:
        priorityColor = AppColors.expenseRed;
        priorityText = tr('wishlist_priority_high');
        break;
      case WishlistPriority.medium:
        priorityColor = AppColors.warningAmber;
        priorityText = tr('wishlist_priority_medium');
        break;
      case WishlistPriority.low:
        priorityColor = AppColors.primaryBlue;
        priorityText = tr('wishlist_priority_low');
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
                            priorityText,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: priorityColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppTranslations.translateCategory(item.category, ref.watch(appLanguageProvider)),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.formatCents(item.priceCents),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
              ),
            ],
          ),
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.notes!,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!item.isPurchased)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(tr('wishlist_mark_purchased_btn'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => MarkPurchasedModal.show(context, item),
                ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => AddWishlistModal.show(context, existingItem: item),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed, size: 18),
                onPressed: () async {
                  await ref.read(wishlistRepositoryProvider).deleteWishlistItem(item.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseHistoryTab(BuildContext context, bool isDark, String Function(String) tr) {
    final purchasesAsync = ref.watch(watchAllPurchasesProvider);

    return purchasesAsync.when(
      data: (purchases) {
        final totalSpentCents = purchases.fold<int>(0, (sum, item) => sum + item.amountCents);

        final filteredPurchases = purchases.where((p) {
          if (_purchaseSearchQuery.isEmpty) return true;
          final q = _purchaseSearchQuery.toLowerCase();
          return p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              (p.notes != null && p.notes!.toLowerCase().contains(q));
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                onChanged: (val) => setState(() => _purchaseSearchQuery = val),
                decoration: InputDecoration(
                  hintText: tr('wishlist_history_search_hint'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _purchaseSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _purchaseSearchQuery = ''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Total Purchase History Value Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('wishlist_total_spent'),
                          style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatCents(totalSpentCents),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_bag, color: AppColors.successGreen, size: 24),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (filteredPurchases.isEmpty)
                _buildEmptyState(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: tr('wishlist_empty_history_title'),
                  subtitle: tr('wishlist_empty_history_sub'),
                  isDark: isDark,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredPurchases.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = filteredPurchases[index];
                    return _buildPurchaseCard(context, p, isDark);
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading purchases: $err')),
    );
  }

  Widget _buildPurchaseCard(BuildContext context, PurchaseEntity p, bool isDark) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                CurrencyFormatter.formatCents(p.amountCents),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.successGreen),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                DateFormatters.formatDate(p.purchaseDate),
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              if (p.notes != null && p.notes!.isNotEmpty) ...[
                Text(' • ', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                Text(
                  p.notes!,
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(AppTranslations.translateCategory(p.category, ref.watch(appLanguageProvider)), style: const TextStyle(fontSize: 11)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed, size: 18),
                onPressed: () async {
                  await ref.read(wishlistRepositoryProvider).deletePurchase(p.id);
                },
              ),
            ],
          ),
        ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            Icon(icon, size: 64, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMainDark : AppColors.textMainLight),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }
}
