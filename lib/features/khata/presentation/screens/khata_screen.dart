import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/navigation_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/borrowed_record.dart';
import '../providers/khata_providers.dart';
import '../widgets/add_borrowed_lent_modal.dart';
import 'khata_detail_screen.dart';
import 'manage_persons_screen.dart';

class KhataScreen extends ConsumerStatefulWidget {
  const KhataScreen({super.key});

  @override
  ConsumerState<KhataScreen> createState() => _KhataScreenState();
}

class _KhataScreenState extends ConsumerState<KhataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: ref.read(khataSubTabProvider),
    );
    _tabController.addListener(() {
      setState(() {});
      if (!_tabController.indexIsChanging) {
        ref.read(khataSubTabProvider.notifier).state = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(khataSubTabProvider, (prev, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(next);
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBorrowedTab = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khata (Borrow & Lend)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            tooltip: 'Manage People',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagePersonsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isBorrowedTab ? AppColors.warningAmber : AppColors.primaryBlue,
          labelColor: isBorrowedTab ? AppColors.warningAmber : AppColors.primaryBlue,
          unselectedLabelColor:
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          tabs: const [
            Tab(text: 'I Borrowed (I Owe)'),
            Tab(text: 'I Lent (Others Owe Me)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BorrowedTab(isDark: isDark),
          _LentTab(isDark: isDark),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 140,
        child: FloatingActionButton.extended(
          backgroundColor: isBorrowedTab ? AppColors.warningAmber : AppColors.primaryBlue,
          foregroundColor: Colors.white,
          onPressed: () {
            AddBorrowedLentModal.show(context, isBorrowed: isBorrowedTab);
          },
          icon: const Icon(Icons.add),
          label: Text(
            isBorrowedTab ? 'Borrowed' : 'Lent',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _BorrowedTab extends ConsumerWidget {
  final bool isDark;
  const _BorrowedTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borrowedAsync = ref.watch(watchAllBorrowedRecordsProvider);

    return borrowedAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return _buildEmptyState(
            isDark,
            title: 'Koi Udhaar Record Nahi 🎉',
            subtitle: 'Apka koi udhaar record nahi hai — sab clear hai!',
            icon: Icons.handshake_outlined,
          );
        }

        final totalRemaining = records
            .where((r) => r.status != DebtStatus.fullyPaid)
            .fold<int>(0, (sum, r) => sum + r.remainingCents);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total You Owe',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatCents(totalRemaining),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.expenseRed,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warningAmber.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_downward, color: AppColors.warningAmber),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Record Cards List
            ...records.map((r) => _buildRecordCard(context, r, true, isDark)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}

class _LentTab extends ConsumerWidget {
  final bool isDark;
  const _LentTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lentAsync = ref.watch(watchAllLentRecordsProvider);

    return lentAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return _buildEmptyState(
            isDark,
            title: 'No Lent Money Records 🤝',
            subtitle: 'Kisi ko pese diye hain? Log them here!',
            icon: Icons.savings_outlined,
          );
        }

        final totalRemaining = records
            .where((r) => r.status != DebtStatus.fullyPaid)
            .fold<int>(0, (sum, r) => sum + r.remainingCents);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Others Owe You',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatCents(totalRemaining),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward, color: AppColors.primaryBlue),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Record Cards List
            ...records.map((r) => _buildRecordCard(context, r, false, isDark)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}

Widget _buildRecordCard(BuildContext context, dynamic record, bool isBorrowed, bool isDark) {
  final String personName = record.personName;
  final int totalCents = record.totalAmountCents;
  final int paidCents = record.paidAmountCents;
  final int remainingCents = record.remainingCents;
  final DebtStatus status = record.status;
  final DateTime date = record.date;

  final statusColor = (remainingCents <= 0 || status == DebtStatus.fullyPaid)
      ? AppColors.successGreen
      : (status == DebtStatus.partiallyPaid ? AppColors.primaryBlue : AppColors.warningAmber);

  final statusLabel = (remainingCents <= 0 || status == DebtStatus.fullyPaid)
      ? 'Fully Paid'
      : (status == DebtStatus.partiallyPaid ? 'Partially Paid' : 'Pending');

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: (isBorrowed ? AppColors.warningAmber : AppColors.primaryBlue).withOpacity(0.12),
        child: Text(
          personName.isNotEmpty ? personName[0].toUpperCase() : '?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isBorrowed ? AppColors.warningAmber : AppColors.primaryBlue,
          ),
        ),
      ),
      title: Text(
        personName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Total: ${CurrencyFormatter.formatCents(totalCents)} • Paid: ${CurrencyFormatter.formatCents(paidCents)}\n${DateFormatters.formatDate(date)}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            CurrencyFormatter.formatCents(remainingCents),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isBorrowed ? AppColors.expenseRed : AppColors.successGreen,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Remaining',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KhataDetailScreen(
              recordType: isBorrowed ? 'borrowed' : 'lent',
              recordId: record.id,
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildEmptyState(
  bool isDark, {
  required String title,
  required String subtitle,
  required IconData icon,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    ),
  );
}
