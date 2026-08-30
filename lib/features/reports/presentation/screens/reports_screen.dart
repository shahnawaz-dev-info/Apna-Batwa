import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../khata/presentation/providers/khata_providers.dart';
import '../providers/analytics_providers.dart';
import '../providers/reports_providers.dart' hide DateTimeRange;

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
    final activeDateRange = ref.watch(analyticsDateRangeProvider);

    final spendingTrends = ref.watch(spendingTrendsProvider);
    final categoryInsight = ref.watch(categoryInsightsProvider);
    final dayOfWeekPattern = ref.watch(dayOfWeekPatternProvider);
    final khataAnalytics = ref.watch(khataAnalyticsProvider);
    final savingsRate = ref.watch(savingsRateAnalyticsProvider);
    final predictiveInsight = ref.watch(predictiveInsightProvider);

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
            // FEATURE 7: Custom Date Range Selector Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...AnalyticsTimeRangeType.values.map((type) {
                    final isSelected = activeDateRange.type == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: isSelected,
                        label: Text(type.label),
                        selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primaryBlue
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        onSelected: (val) async {
                          if (val) {
                            final now = DateTime.now();
                            if (type == AnalyticsTimeRangeType.custom) {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                initialDateRange: DateTimeRange(
                                  start: activeDateRange.start,
                                  end: activeDateRange.end,
                                ),
                              );
                              if (picked != null) {
                                ref.read(analyticsDateRangeProvider.notifier).state = AnalyticsDateRange(
                                  type: AnalyticsTimeRangeType.custom,
                                  start: picked.start,
                                  end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
                                );
                              }
                            } else {
                              DateTime start;
                              DateTime end;
                              switch (type) {
                                case AnalyticsTimeRangeType.thisMonth:
                                  start = DateTime(now.year, now.month, 1);
                                  end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                                  break;
                                case AnalyticsTimeRangeType.last3Months:
                                  start = DateTime(now.year, now.month - 2, 1);
                                  end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                                  break;
                                case AnalyticsTimeRangeType.last6Months:
                                  start = DateTime(now.year, now.month - 5, 1);
                                  end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                                  break;
                                case AnalyticsTimeRangeType.thisYear:
                                  start = DateTime(now.year, 1, 1);
                                  end = DateTime(now.year, 12, 31, 23, 59, 59);
                                  break;
                                case AnalyticsTimeRangeType.allTime:
                                  start = DateTime(2000, 1, 1);
                                  end = DateTime(2099, 12, 31);
                                  break;
                                default:
                                  start = DateTime(now.year, now.month, 1);
                                  end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                              }
                              ref.read(analyticsDateRangeProvider.notifier).state = AnalyticsDateRange(
                                type: type,
                                start: start,
                                end: end,
                              );
                            }
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (activeDateRange.type == AnalyticsTimeRangeType.custom) ...[
              const SizedBox(height: 8),
              Text(
                'Range: ${DateFormatters.formatShortDate(activeDateRange.start)} - ${DateFormatters.formatShortDate(activeDateRange.end)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
            const SizedBox(height: 20),

            // FEATURE 6: Predictive Insight Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.insights_outlined, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PREDICTIVE INSIGHT (MOVING AVG)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          predictiveInsight.insightSentence,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FEATURE 5: Savings Rate Section
            _buildSectionCard(
              context,
              isDark: isDark,
              title: 'Savings Rate',
              subtitle: 'Percentage of income saved for ${activeDateRange.type.label}',
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              savingsRate.savingsRatePercentage != null
                                  ? '${savingsRate.savingsRatePercentage!.toStringAsFixed(1)}%'
                                  : 'N/A',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: savingsRate.savingsRatePercentage == null
                                    ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                                    : (savingsRate.savingsRatePercentage! >= 0
                                        ? AppColors.successGreen
                                        : AppColors.expenseRed),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              savingsRate.labelSentence,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (savingsRate.savingsRatePercentage != null && savingsRate.savingsRatePercentage! >= 0
                                  ? AppColors.successGreen
                                  : AppColors.expenseRed)
                              .withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          savingsRate.savingsRatePercentage != null && savingsRate.savingsRatePercentage! >= 0
                              ? Icons.savings_outlined
                              : Icons.warning_amber_outlined,
                          color: savingsRate.savingsRatePercentage != null && savingsRate.savingsRatePercentage! >= 0
                              ? AppColors.successGreen
                              : AppColors.expenseRed,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FEATURE 1: Spending Trends (6-Month Monthly Comparison)
            _buildSectionCard(
              context,
              isDark: isDark,
              title: 'Spending Trends (Monthly Comparison)',
              subtitle: 'Expense history over last 6 months',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Callout badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (spendingTrends.isExpenseIncreased ? AppColors.expenseRed : AppColors.successGreen)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          spendingTrends.isExpenseIncreased ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14,
                          color: spendingTrends.isExpenseIncreased ? AppColors.expenseRed : AppColors.successGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          spendingTrends.changeCallout,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: spendingTrends.isExpenseIncreased ? AppColors.expenseRed : AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
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
                                if (index >= 0 && index < spendingTrends.monthlyPoints.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      spendingTrends.monthlyPoints[index].label,
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
                        barGroups: List.generate(spendingTrends.monthlyPoints.length, (index) {
                          final pt = spendingTrends.monthlyPoints[index];
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: pt.expenseCents.toDouble() / 100.0,
                                color: AppColors.expenseRed,
                                width: 16,
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

            // FEATURE 2: Category Breakdown Insights
            _buildSectionCard(
              context,
              isDark: isDark,
              title: 'Category Breakdown Insights',
              subtitle: 'Expense distribution for ${activeDateRange.type.label}',
              child: categoryInsight.items.isEmpty
                  ? _buildEmptyState(isDark, 'No expense data available for this period.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Auto-written insight banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, color: AppColors.primaryBlue, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  categoryInsight.insightSentence,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: List.generate(categoryInsight.items.length, (index) {
                                final item = categoryInsight.items[index];
                                final color = _chartColors[index % _chartColors.length];
                                return PieChartSectionData(
                                  color: color,
                                  value: item.totalCents.toDouble(),
                                  title: '${item.percentage.toStringAsFixed(0)}%',
                                  radius: 40,
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
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryInsight.items.length,
                          separatorBuilder: (_, __) => const Divider(height: 12),
                          itemBuilder: (context, index) {
                            final item = categoryInsight.items[index];
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

            // FEATURE 3: Income vs Expense Pattern (by day of week)
            _buildSectionCard(
              context,
              isDark: isDark,
              title: 'Spending Pattern by Day of Week',
              subtitle: 'Daily expense volume analysis',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningAmber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.warningAmber, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            dayOfWeekPattern.calloutSentence,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warningAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
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
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                final index = val.toInt();
                                if (index >= 0 && index < 7) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      days[index],
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
                        barGroups: List.generate(7, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: dayOfWeekPattern.totalCentsPerDay[index].toDouble() / 100.0,
                                color: AppColors.primaryBlue,
                                width: 14,
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

            // FEATURE 4: Khata Insights Summary
            _buildSectionCard(
              context,
              isDark: isDark,
              title: 'Khata Insights Summary',
              subtitle: 'Overall borrowing, lending, and contact activity',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.expenseRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Borrowed', style: TextStyle(fontSize: 11, color: AppColors.expenseRed)),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.formatCents(khataAnalytics.totalBorrowedCents),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.expenseRed),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Repaid: ${CurrencyFormatter.formatCents(khataAnalytics.totalRepaidCents)}',
                                style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Lent', style: TextStyle(fontSize: 11, color: AppColors.successGreen)),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.formatCents(khataAnalytics.totalLentCents),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Received: ${CurrencyFormatter.formatCents(khataAnalytics.totalReceivedCents)}',
                                style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (khataAnalytics.netPositionCents >= 0 ? AppColors.successGreen : AppColors.expenseRed).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Net Khata Position', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${khataAnalytics.netPositionCents >= 0 ? "+" : ""}${CurrencyFormatter.formatCents(khataAnalytics.netPositionCents)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: khataAnalytics.netPositionCents >= 0 ? AppColors.successGreen : AppColors.expenseRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (khataAnalytics.topActiveContacts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'MOST ACTIVE KHATA CONTACTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: khataAnalytics.topActiveContacts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final c = khataAnalytics.topActiveContacts[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.borderDark : AppColors.borderLight).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    c.personName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                              Text(
                                'Vol: ${CurrencyFormatter.formatCents(c.totalVolumeCents)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
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
