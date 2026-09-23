import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/providers/theme_providers.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

class BankReceiptModal extends ConsumerWidget {
  final CombinedTransactionItem item;

  const BankReceiptModal({super.key, required this.item});

  static Future<void> show(BuildContext context, CombinedTransactionItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BankReceiptModal(item: item),
    );
  }

  String get _refId {
    return 'BATWA-${item.id.toUpperCase().replaceAll('-', '').padRight(8).substring(0, 8)}';
  }

  void _shareViaWhatsApp(BuildContext context, String bankName) {
    final dateTimeStr = DateFormatters.formatDateTime(item.date);
    final amountStr = '${item.isIncome ? "+" : "-"}${CurrencyFormatter.formatCents(item.amountCents)}';

    final text = '''
🏛️ *$bankName Official Transaction Receipt*
━━━━━━━━━━━━━━━━━━━━━━
✅ *Status:* Successful
💰 *Amount:* $amountStr
📁 *Category:* ${item.title}
📅 *Date & Time:* $dateTimeStr
🔢 *Ref ID:* #$_refId
${item.subtitle != null && item.subtitle!.isNotEmpty ? "📝 *Details:* ${item.subtitle}\n" : ""}━━━━━━━━━━━━━━━━━━━━━━
_Generated securely via Apna Batwa_
''';

    Share.share(text.trim(), subject: '$bankName Transaction Receipt');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBank = ref.watch(activeBankConfigProvider);
    final formattedAmount = '${item.isIncome ? "+" : "-"}${CurrencyFormatter.formatCents(item.amountCents)}';
    final dateTimeStr = DateFormatters.formatDateTime(item.date);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Bank Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: activeBank.cardGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(activeBank.bankIcon, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeBank.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'OFFICIAL E-RECEIPT',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 9,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 2. Success Checkmark
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.successGreen,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Transaction Successful',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 3. Amount Display
                    Text(
                      formattedAmount,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: item.isIncome ? AppColors.successGreen : AppColors.expenseRed,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // 4. Receipt Fields
                    _buildRow(
                      'Reference ID',
                      '#$_refId',
                      isDark: isDark,
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _buildRow(
                      'Type',
                      item.isIncome ? 'Income / Money In' : 'Expense / Money Out',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildRow(
                      'Category',
                      item.title,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildRow(
                      'Date & Time',
                      dateTimeStr,
                      isDark: isDark,
                    ),
                    if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildRow(
                        'Note',
                        item.subtitle!,
                        isDark: isDark,
                      ),
                    ],

                    const SizedBox(height: 20),

                    // 5. Action Buttons (WhatsApp Share & PDF Download)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _shareViaWhatsApp(context, activeBank.name),
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text(
                              'WhatsApp',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: activeBank.primaryColor,
                              side: BorderSide(color: activeBank.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              await PdfExportService.instance.exportSingleTransactionReceiptPdf(
                                item: item,
                                bankName: activeBank.name,
                              );
                            },
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text(
                              'Save PDF',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {required bool isDark, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
