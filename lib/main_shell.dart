import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_translations.dart';
import 'core/providers/navigation_providers.dart';
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
    final tr = ref.watch(translationsProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(selectedMainTabProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: tr('tab_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: tr('tab_transactions'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: tr('tab_khata'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pie_chart_outline),
            activeIcon: const Icon(Icons.pie_chart),
            label: tr('tab_reports'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz_outlined),
            activeIcon: const Icon(Icons.more_horiz),
            label: tr('tab_more'),
          ),
        ],
      ),
    );
  }
}
