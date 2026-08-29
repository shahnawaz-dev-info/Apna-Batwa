import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../khata/presentation/providers/khata_providers.dart';
import '../providers/reports_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const List<Color> _chartColors = [
    AppColors.primaryBlue,
    AppColors.expenseRed,
    AppColors.successGreen,
    AppColors.warningAmber,
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF97316), // Orange
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedRange = ref.watch(reportTimeRangeProvider);
    final categoryReport = ref.watch(categoryExpenseReportProvider);
    final trendPoints = ref.watch(incomeExpenseTrendProvider);
    final khataSummary = ref.watch(khataSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF Report',
            onPressed: () async {
              final summaryData = khataSummary.maybeWhen(
                data: (d) => d,
                orElse: () => KhataSummaryData(
                  totalBorrowedCents: 0,
                  totalLentCents: 0,
                ),
              );
              await PdfExportService.instance.exportReportsPdf(
                range: selectedRange,
                categoryReport: categoryReport,
                trendPoints: trendPoints,
                khataSummary: summaryData,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Range Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ReportTimeRange.values.map((range) {
                  final isSelected = range == selectedRange;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(range.label),
                      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                      onSelected: (val) {
                        if (val) {
                          ref.read(reportTimeRangeProvider.notifier).state = range;
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // SECTION 1: Category-wise Expense Breakdown
            _buildSectionCard(
              context,
              isDark: isDark,
              title: 'Category-wise Expenses',
              subtitle: 'Distribution of expenses for ${selectedRange.label}',
              child: categoryReport.isEmpty
                  ? _buildEmptyState(isDark, 'No expense data available for this period.')
                  : Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: List.generate(categoryReport.length, (index) {
                                final item = categoryReport[index];
                                final color = _chartColors[index % _chartColors.length];
                                return PieChartSectionData(
                                  color: color,
                                  value: item.totalCents.toDouble(),
                                  title: '${item.percentage.toStringAsFixed(1)}%',
                                  radius: 45,
                                  titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Legend List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryReport.length,
                          separatorBuilder: (_, __) => const Divider(height: 12),
                          itemBuilder: (context, index) {
                            final item = categoryReport[index];
                            final color = _chartColors[index % _chartColors.length];
                            return Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.categoryName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatCents(item.totalCents),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${item.percentage.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // SECTION 2: Income vs Expense Trend
            _buildSectionCard(
              context,
              isDark: isDark,
              title: 'Income vs Expense Trend',
              subtitle: 'Monthly comparison for ${selectedRange.label}',
              child: trendPoints.isEmpty
                  ? _buildEmptyState(isDark, 'No trend data available for this period.')
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendBadge(AppColors.successGreen, 'Income'),
                            const SizedBox(width: 20),
                            _buildLegendBadge(AppColors.expenseRed, 'Expense'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      final index = val.toInt();
                                      if (index >= 0 && index < trendPoints.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            trendPoints[index].label,
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(trendPoints.length, (index) {
                                final pt = trendPoints[index];
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: pt.incomeCents.toDouble() / 100.0,
                                      color: AppColors.successGreen,
                                      width: 12,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    BarChartRodData(
                                      toY: pt.expenseCents.toDouble() / 100.0,
                                      color: AppColors.expenseRed,
                                      width: 12,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // SECTION 3: Khata Summary
            _buildSectionCard(
              context,
              isDark: isDark,
              title: 'Khata Summary',
              subtitle: 'Current borrowed vs lent balances',
              child: khataSummary.when(
                data: (data) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.expenseRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('You Owe (Borrowed)', style: TextStyle(fontSize: 12, color: AppColors.expenseRed)),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.formatCents(data.totalBorrowedCents),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.expenseRed),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.successGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Others Owe You', style: TextStyle(fontSize: 12, color: AppColors.successGreen)),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.formatCents(data.totalLentCents),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (data.netBalanceCents >= 0 ? AppColors.successGreen : AppColors.expenseRed).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Net Khata Position', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${data.netBalanceCents >= 0 ? "+" : ""}${CurrencyFormatter.formatCents(data.netBalanceCents)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: data.netBalanceCents >= 0 ? AppColors.successGreen : AppColors.expenseRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading khata summary: $err'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMainDark : AppColors.textMainLight)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildLegendBadge(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
      ),
    );
  }
}
