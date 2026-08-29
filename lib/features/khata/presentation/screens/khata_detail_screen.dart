import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/borrowed_record.dart';
import '../../domain/entities/lent_record.dart';
import '../providers/khata_providers.dart';
import '../widgets/add_borrowed_lent_modal.dart';
import '../widgets/add_repayment_modal.dart';

class KhataDetailScreen extends ConsumerWidget {
  final String recordType; // 'borrowed' or 'lent'
  final int recordId;

  const KhataDetailScreen({
    super.key,
    required this.recordType,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBorrowed = recordType == 'borrowed';

    final borrowedAsync = isBorrowed ? ref.watch(watchAllBorrowedRecordsProvider) : null;
    final lentAsync = !isBorrowed ? ref.watch(watchAllLentRecordsProvider) : null;

    final repaymentsAsync = ref.watch(
      watchRepaymentsForRecordProvider(
        RepaymentRecordParam(recordType: recordType, recordId: recordId),
      ),
    );

    BorrowedRecordEntity? borrowedRecord;
    LentRecordEntity? lentRecord;

    if (isBorrowed) {
      borrowedRecord = borrowedAsync?.maybeWhen(
        data: (list) => list.firstWhere((r) => r.id == recordId, orElse: () => list.first),
        orElse: () => null,
      );
    } else {
      lentRecord = lentAsync?.maybeWhen(
        data: (list) => list.firstWhere((r) => r.id == recordId, orElse: () => list.first),
        orElse: () => null,
      );
    }

    final personName = borrowedRecord?.personName ?? lentRecord?.personName ?? 'Khata Detail';
    final totalCents = borrowedRecord?.totalAmountCents ?? lentRecord?.totalAmountCents ?? 0;
    final paidCents = borrowedRecord?.paidAmountCents ?? lentRecord?.paidAmountCents ?? 0;
    final remainingCents = borrowedRecord?.remainingCents ?? lentRecord?.remainingCents ?? 0;
    final status = borrowedRecord?.status ?? lentRecord?.status ?? DebtStatus.pending;
    final date = borrowedRecord?.date ?? lentRecord?.date ?? DateTime.now();
    final note = borrowedRecord?.note ?? lentRecord?.note;

    final statusColor = status == DebtStatus.overpaid
        ? AppColors.primaryBlue
        : (status == DebtStatus.fullyPaid
            ? AppColors.successGreen
            : (status == DebtStatus.partiallyPaid ? AppColors.primaryBlue : AppColors.warningAmber));

    final statusLabel = status == DebtStatus.overpaid
        ? 'Overpaid by ${CurrencyFormatter.formatCents(remainingCents.abs())}'
        : (status == DebtStatus.fullyPaid
            ? 'Fully Paid'
            : (status == DebtStatus.partiallyPaid ? 'Partially Paid' : 'Pending'));

    return Scaffold(
      appBar: AppBar(
        title: Text(personName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              if (isBorrowed && borrowedRecord != null) {
                AddBorrowedLentModal.show(
                  context,
                  isBorrowed: true,
                  existingBorrowed: borrowedRecord,
                );
              } else if (!isBorrowed && lentRecord != null) {
                AddBorrowedLentModal.show(
                  context,
                  isBorrowed: false,
                  existingLent: lentRecord,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed),
            onPressed: () => _confirmDeleteRecord(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBorrowed ? 'I Borrowed' : 'I Lent',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Remaining Amount Display
                  Text(
                    remainingCents < 0
                        ? '−${CurrencyFormatter.formatCents(remainingCents.abs())}'
                        : CurrencyFormatter.formatCents(remainingCents),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isBorrowed ? AppColors.expenseRed : AppColors.successGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Remaining Balance',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Divider(),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailStat('Total Amount', CurrencyFormatter.formatCents(totalCents), isDark),
                      _buildDetailStat('Paid So Far', CurrencyFormatter.formatCents(paidCents), isDark),
                      _buildDetailStat('Date', DateFormatters.formatDate(date), isDark),
                    ],
                  ),

                  if (note != null && note.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Note: $note',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Repayment Action Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Repayment History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                  ),
                ),
                if (status != DebtStatus.fullyPaid)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBorrowed ? AppColors.successGreen : AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      AddRepaymentModal.show(
                        context,
                        recordType: recordType,
                        recordId: recordId,
                        remainingCents: remainingCents,
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text(isBorrowed ? '+ Return Money' : '+ Receive Money'),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Repayment History List
            repaymentsAsync.when(
              data: (repayments) {
                if (repayments.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_outlined,
                          size: 40,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No repayments logged yet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: repayments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = repayments[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_outline, color: AppColors.successGreen, size: 20),
                        ),
                        title: Text(
                          CurrencyFormatter.formatCents(item.amountCents),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          '${DateFormatters.formatDate(item.date)}${item.note != null ? " • ${item.note}" : ""}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed, size: 20),
                          onPressed: () => _confirmDeleteRepayment(context, ref, item.id),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading repayments: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
      ],
    );
  }

  void _confirmDeleteRecord(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Khata Entry'),
        content: const Text('Are you sure you want to delete this record and all its repayment logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(khataRepositoryProvider);
              if (recordType == 'borrowed') {
                await repo.deleteBorrowedRecord(recordId);
              } else {
                await repo.deleteLentRecord(recordId);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRepayment(BuildContext context, WidgetRef ref, int repaymentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Repayment'),
        content: const Text('Are you sure you want to delete this repayment log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(khataRepositoryProvider);
              await repo.deleteRepayment(repaymentId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
