import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the active tab in MainShell
/// 0: Home / Dashboard
/// 1: Transactions
/// 2: Khata
/// 3: Wishlist
/// 4: More
final selectedMainTabProvider = StateProvider<int>((ref) => 0);

/// Sub-tab index for TransactionsScreen
/// 0: All History
/// 1: Income
/// 2: Expenses
final transactionsSubTabProvider = StateProvider<int>((ref) => 0);

/// Sub-tab index for KhataScreen
/// 0: I Borrowed (I Owe)
/// 1: I Lent (Others Owe Me)
final khataSubTabProvider = StateProvider<int>((ref) => 0);
