import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Tokens
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color successGreen = Color(0xFF10B981);
  static const Color expenseRed = Color(0xFFEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);
  
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textMainLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark Mode Tokens
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textMainDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Accent Gradients & Surfaces
  static const LinearGradient balanceGradientLight = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceGradientDark = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

enum BankThemePreset {
  defaultBatwa,
  sadapay,
  nayapay,
  meezan,
  hbl,
  ubl,
}

class BankThemeConfig {
  final BankThemePreset preset;
  final String id;
  final String name;
  final String subtitle;
  final Color primaryColor;
  final Color accentColor;
  final LinearGradient cardGradient;
  final Color cardTextColor;
  final Color chipColor;
  final IconData bankIcon;

  const BankThemeConfig({
    required this.preset,
    required this.id,
    required this.name,
    required this.subtitle,
    required this.primaryColor,
    required this.accentColor,
    required this.cardGradient,
    required this.cardTextColor,
    required this.chipColor,
    required this.bankIcon,
  });

  static const BankThemeConfig defaultBatwa = BankThemeConfig(
    preset: BankThemePreset.defaultBatwa,
    id: 'defaultBatwa',
    name: 'Apna Batwa',
    subtitle: 'Classic Digital Wallet',
    primaryColor: Color(0xFF0F172A),
    accentColor: Color(0xFF2563EB),
    cardGradient: LinearGradient(
      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardTextColor: Colors.white,
    chipColor: Color(0xFFFFD700),
    bankIcon: Icons.account_balance_wallet_rounded,
  );

  static const BankThemeConfig sadapay = BankThemeConfig(
    preset: BankThemePreset.sadapay,
    id: 'sadapay',
    name: 'SadaPay',
    subtitle: 'Goodbye Traditional Banking',
    primaryColor: Color(0xFFFF6B57),
    accentColor: Color(0xFF00D09C),
    cardGradient: LinearGradient(
      colors: [Color(0xFFFF6B57), Color(0xFFFF8C7A), Color(0xFF2E1C2B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardTextColor: Colors.white,
    chipColor: Color(0xFFFFD700),
    bankIcon: Icons.flash_on_rounded,
  );

  static const BankThemeConfig nayapay = BankThemeConfig(
    preset: BankThemePreset.nayapay,
    id: 'nayapay',
    name: 'NayaPay',
    subtitle: 'Payments Made Easy',
    primaryColor: Color(0xFFFF5A00),
    accentColor: Color(0xFF1A202C),
    cardGradient: LinearGradient(
      colors: [Color(0xFFFF5A00), Color(0xFFFF7D33), Color(0xFFD64400)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardTextColor: Colors.white,
    chipColor: Color(0xFFFFE082),
    bankIcon: Icons.all_inclusive_rounded,
  );

  static const BankThemeConfig meezan = BankThemeConfig(
    preset: BankThemePreset.meezan,
    id: 'meezan',
    name: 'Meezan Bank',
    subtitle: 'Premier Islamic Banking',
    primaryColor: Color(0xFF003366),
    accentColor: Color(0xFFC5A059),
    cardGradient: LinearGradient(
      colors: [Color(0xFF001F3F), Color(0xFF003366), Color(0xFFC5A059)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardTextColor: Colors.white,
    chipColor: Color(0xFFE5C158),
    bankIcon: Icons.account_balance_rounded,
  );

  static const BankThemeConfig hbl = BankThemeConfig(
    preset: BankThemePreset.hbl,
    id: 'hbl',
    name: 'HBL',
    subtitle: 'Habib Bank Limited',
    primaryColor: Color(0xFF008269),
    accentColor: Color(0xFF03362A),
    cardGradient: LinearGradient(
      colors: [Color(0xFF008269), Color(0xFF005E4C), Color(0xFF023E32)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardTextColor: Colors.white,
    chipColor: Color(0xFFFFD700),
    bankIcon: Icons.assured_workload_rounded,
  );

  static const BankThemeConfig ubl = BankThemeConfig(
    preset: BankThemePreset.ubl,
    id: 'ubl',
    name: 'UBL',
    subtitle: 'United Bank Limited',
    primaryColor: Color(0xFF0055A5),
    accentColor: Color(0xFFFFC72C),
    cardGradient: LinearGradient(
      colors: [Color(0xFF003E78), Color(0xFF0055A5), Color(0xFF0072CE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardTextColor: Colors.white,
    chipColor: Color(0xFFFFD700),
    bankIcon: Icons.shield_rounded,
  );

  static List<BankThemeConfig> get allBanks => [
    defaultBatwa,
    sadapay,
    nayapay,
    meezan,
    hbl,
    ubl,
  ];

  static BankThemeConfig getConfig(BankThemePreset preset) {
    switch (preset) {
      case BankThemePreset.sadapay:
        return sadapay;
      case BankThemePreset.nayapay:
        return nayapay;
      case BankThemePreset.meezan:
        return meezan;
      case BankThemePreset.hbl:
        return hbl;
      case BankThemePreset.ubl:
        return ubl;
      case BankThemePreset.defaultBatwa:
      default:
        return defaultBatwa;
    }
  }

  static BankThemePreset fromId(String? id) {
    switch (id) {
      case 'sadapay':
        return BankThemePreset.sadapay;
      case 'nayapay':
        return BankThemePreset.nayapay;
      case 'meezan':
        return BankThemePreset.meezan;
      case 'hbl':
        return BankThemePreset.hbl;
      case 'ubl':
        return BankThemePreset.ubl;
      case 'defaultBatwa':
      default:
        return BankThemePreset.defaultBatwa;
    }
  }
}
