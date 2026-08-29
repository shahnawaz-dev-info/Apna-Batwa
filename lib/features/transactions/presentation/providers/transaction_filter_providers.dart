import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

class TransactionFilterState {
  final String searchQuery;
  final String typeFilter; // 'all', 'income', 'expense'
  final Set<String> selectedCategories;
  final DateTimeRange? dateRange;
  final int? minAmountCents;
  final int? maxAmountCents;

  const TransactionFilterState({
    this.searchQuery = '',
    this.typeFilter = 'all',
    this.selectedCategories = const {},
    this.dateRange,
    this.minAmountCents,
    this.maxAmountCents,
  });

  bool get hasActiveFilters =>
      typeFilter != 'all' ||
      selectedCategories.isNotEmpty ||
      dateRange != null ||
      minAmountCents != null ||
      maxAmountCents != null;

  TransactionFilterState copyWith({
    String? searchQuery,
    String? typeFilter,
    Set<String>? selectedCategories,
    DateTimeRange? dateRange,
    int? Function()? minAmountCents,
    int? Function()? maxAmountCents,
  }) {
    return TransactionFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      dateRange: dateRange ?? this.dateRange,
      minAmountCents: minAmountCents != null ? minAmountCents() : this.minAmountCents,
      maxAmountCents: maxAmountCents != null ? maxAmountCents() : this.maxAmountCents,
    );
  }

  TransactionFilterState clearFilters() {
    return TransactionFilterState(
      searchQuery: searchQuery,
    );
  }
}

class TransactionFilterNotifier extends StateNotifier<TransactionFilterState> {
  TransactionFilterNotifier() : super(const TransactionFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setTypeFilter(String type) {
    state = state.copyWith(typeFilter: type);
  }

  void toggleCategory(String category) {
    final updated = Set<String>.from(state.selectedCategories);
    if (updated.contains(category)) {
      updated.remove(category);
    } else {
      updated.add(category);
    }
    state = state.copyWith(selectedCategories: updated);
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  void setAmountRange(int? minCents, int? maxCents) {
    state = state.copyWith(
      minAmountCents: () => minCents,
      maxAmountCents: () => maxCents,
    );
  }

  void clearAll() {
    state = state.clearFilters();
  }
}

final transactionFilterProvider =
    StateNotifierProvider<TransactionFilterNotifier, TransactionFilterState>((ref) {
  return TransactionFilterNotifier();
});

final filteredTransactionsProvider = Provider<List<CombinedTransactionItem>>((ref) {
  final allTransactions = ref.watch(recentTransactionsProvider);
  final filter = ref.watch(transactionFilterProvider);

  return allTransactions.where((item) {
    // 1. Search Query Filter (name/title/note/subtitle)
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      final titleMatch = item.title.toLowerCase().contains(query);
      final subtitleMatch = item.subtitle?.toLowerCase().contains(query) ?? false;
      if (!titleMatch && !subtitleMatch) return false;
    }

    // 2. Type Filter
    if (filter.typeFilter == 'income' && !item.isIncome) return false;
    if (filter.typeFilter == 'expense' && item.isIncome) return false;

    // 3. Category Filter
    if (filter.selectedCategories.isNotEmpty) {
      final itemCategory = item.title.toLowerCase();
      final matchesAnyCategory = filter.selectedCategories.any(
        (c) => c.toLowerCase() == itemCategory || (item.subtitle?.toLowerCase().contains(c.toLowerCase()) ?? false),
      );
      if (!matchesAnyCategory) return false;
    }

    // 4. Date Range Filter
    if (filter.dateRange != null) {
      final itemDate = DateTime(item.date.year, item.date.month, item.date.day);
      final startDate = DateTime(filter.dateRange!.start.year, filter.dateRange!.start.month, filter.dateRange!.start.day);
      final endDate = DateTime(filter.dateRange!.end.year, filter.dateRange!.end.month, filter.dateRange!.end.day, 23, 59, 59);

      if (itemDate.isBefore(startDate) || itemDate.isAfter(endDate)) {
        return false;
      }
    }

    // 5. Amount Range Filter
    if (filter.minAmountCents != null && item.amountCents < filter.minAmountCents!) {
      return false;
    }
    if (filter.maxAmountCents != null && item.amountCents > filter.maxAmountCents!) {
      return false;
    }

    return true;
  }).toList();
});
