import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_translations.dart';
import 'core/providers/navigation_providers.dart';
import 'core/providers/theme_providers.dart';
import 'core/widgets/fintech_bouncing_widget.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/khata/presentation/screens/khata_screen.dart';
import 'features/more/presentation/screens/more_screen.dart';
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/transactions/presentation/screens/transactions_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const List<Widget> _screens = [
    DashboardScreen(),
    TransactionsScreen(),
    KhataScreen(),
    ReportsScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(selectedMainTabProvider);
    final bankConfig = ref.watch(activeBankConfigProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = ref.watch(translationsProvider);

    final tabs = [
      _TabItem(icon: Icons.home_rounded, unselectedIcon: Icons.home_outlined, label: tr('tab_home')),
      _TabItem(icon: Icons.receipt_long_rounded, unselectedIcon: Icons.receipt_long_outlined, label: tr('tab_transactions')),
      _TabItem(icon: Icons.menu_book_rounded, unselectedIcon: Icons.menu_book_outlined, label: tr('tab_khata')),
      _TabItem(icon: Icons.pie_chart_rounded, unselectedIcon: Icons.pie_chart_outline, label: tr('tab_reports')),
      _TabItem(icon: Icons.more_horiz_rounded, unselectedIcon: Icons.more_horiz_outlined, label: tr('tab_more')),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? bankConfig.darkCard : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? bankConfig.darkBorder : bankConfig.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final isSelected = currentIndex == index;
                final tab = tabs[index];

                return Expanded(
                  child: FintechBounce(
                    scaleFactor: 0.92,
                    onTap: () {
                      if (currentIndex != index) {
                        HapticFeedback.lightImpact();
                        ref.read(selectedMainTabProvider.notifier).state = index;
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? bankConfig.primaryColor.withOpacity(isDark ? 0.16 : 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            scale: isSelected ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
                            child: Icon(
                              isSelected ? tab.icon : tab.unselectedIcon,
                              color: isSelected
                                  ? bankConfig.primaryColor
                                  : (isDark ? Colors.grey[500] : Colors.grey[600]),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? bankConfig.primaryColor
                                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData unselectedIcon;
  final String label;

  const _TabItem({
    required this.icon,
    required this.unselectedIcon,
    required this.label,
  });
}
