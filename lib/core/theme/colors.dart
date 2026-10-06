import 'package:flutter/material.dart';

enum BankThemePreset {
  sadapay,
  defaultBatwa,
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
  final Color darkBackground;
  final Color darkCard;
  final Color darkBorder;
  final Color lightBackground;
  final Color lightCard;
  final Color lightBorder;
  final Color glowColor;
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
    required this.darkBackground,
    required this.darkCard,
    required this.darkBorder,
    required this.lightBackground,
    required this.lightCard,
    required this.lightBorder,
    required this.glowColor,
    required this.cardGradient,
    required this.cardTextColor,
    required this.chipColor,
    required this.bankIcon,
  });

  static const BankThemeConfig sadapay = BankThemeConfig(
    preset: BankThemePreset.sadapay,
    id: 'sadapay',
    name: 'SadaPay',
    subtitle: 'Goodbye Traditional Banking',
    primaryColor: Color(0xFFFF6B57), // Signature SadaPay Coral
    accentColor: Color(0xFF00D09C), // SadaPay Electric Mint
    darkBackground: Color(0xFF0F1015), // SadaPay Matte Obsidian
    darkCard: Color(0xFF191B24), // SadaPay Elevated Charcoal
    darkBorder: Color(0xFF262938),
    lightBackground: Color(0xFFF8F9FD),
    lightCard: Color(0xFFFFFFFF),
    lightBorder: Color(0xFFEEEEF4),
    glowColor: Color(0x33FF6B57),
    cardGradient: LinearGradient(
      colors: [Color(0xFFFF6B57), Color(0xFFFF8C7A), Color(0xFF2E1C2B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardTextColor: Colors.white,
    chipColor: Color(0xFFFFD700),
    bankIcon: Icons.flash_on_rounded,
  );

  static const BankThemeConfig defaultBatwa = BankThemeConfig(
    preset: BankThemePreset.defaultBatwa,
    id: 'defaultBatwa',
    name: 'Apna Batwa',
    subtitle: 'Classic Digital Wallet',
    primaryColor: Color(0xFF2563EB),
    accentColor: Color(0xFF10B981),
    darkBackground: Color(0xFF0F172A),
    darkCard: Color(0xFF1E293B),
    darkBorder: Color(0xFF334155),
    lightBackground: Color(0xFFF8FAFC),
    lightCard: Color(0xFFFFFFFF),
    lightBorder: Color(0xFFE2E8F0),
    glowColor: Color(0x332563EB),
    cardGradient: LinearGradient(
      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardTextColor: Colors.white,
    chipColor: Color(0xFFFFD700),
    bankIcon: Icons.account_balance_wallet_rounded,
  );

  static const BankThemeConfig nayapay = BankThemeConfig(
    preset: BankThemePreset.nayapay,
    id: 'nayapay',
    name: 'NayaPay',
    subtitle: 'Payments Made Easy',
    primaryColor: Color(0xFFFF5A00), // NayaPay Vibrant Orange
    accentColor: Color(0xFF00C2A8), // NayaPay Electric Aqua
    darkBackground: Color(0xFF111218),
    darkCard: Color(0xFF1B1D27),
    darkBorder: Color(0xFF2B2E3E),
    lightBackground: Color(0xFFFDF9F7),
    lightCard: Color(0xFFFFFFFF),
    lightBorder: Color(0xFFF2E9E4),
    glowColor: Color(0x33FF5A00),
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
    primaryColor: Color(0xFF004080), // Meezan Royal Blue
    accentColor: Color(0xFFD4AF37), // Islamic Gold
    darkBackground: Color(0xFF0A0F17),
    darkCard: Color(0xFF111A27),
    darkBorder: Color(0xFF1E2D40),
    lightBackground: Color(0xFFF6F8FB),
    lightCard: Color(0xFFFFFFFF),
    lightBorder: Color(0xFFE2E8F0),
    glowColor: Color(0x33004080),
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
    primaryColor: Color(0xFF008269), // HBL Emerald Green
    accentColor: Color(0xFF00BFA5), // Fresh Mint
    darkBackground: Color(0xFF0A1310),
    darkCard: Color(0xFF12221D),
    darkBorder: Color(0xFF1C382F),
    lightBackground: Color(0xFFF5FAF8),
    lightCard: Color(0xFFFFFFFF),
    lightBorder: Color(0xFFE0ECE8),
    glowColor: Color(0x33008269),
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
    primaryColor: Color(0xFF0055A5), // UBL Blue
    accentColor: Color(0xFFFFC72C), // UBL Sunshine Gold
    darkBackground: Color(0xFF09111C),
    darkCard: Color(0xFF121E30),
    darkBorder: Color(0xFF1E304C),
    lightBackground: Color(0xFFF6F9FD),
    lightCard: Color(0xFFFFFFFF),
    lightBorder: Color(0xFFDFE8F4),
    glowColor: Color(0x330055A5),
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
    sadapay,
    defaultBatwa,
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
        return defaultBatwa;
    }
  }

  static BankThemePreset fromId(String? id) {
    switch (id) {
      case 'defaultBatwa':
        return BankThemePreset.defaultBatwa;
      case 'nayapay':
        return BankThemePreset.nayapay;
      case 'meezan':
        return BankThemePreset.meezan;
      case 'hbl':
        return BankThemePreset.hbl;
      case 'ubl':
        return BankThemePreset.ubl;
      case 'sadapay':
      default:
        return BankThemePreset.sadapay;
    }
  }
}

class AppColors {
  static BankThemeConfig _activeBank = BankThemeConfig.sadapay;

  static void setBankConfig(BankThemeConfig config) {
    _activeBank = config;
  }

  static BankThemeConfig get currentBank => _activeBank;

  // Dynamically powered by the selected Bank Theme:
  static Color get primaryBlue => _activeBank.primaryColor;
  static Color get primaryNavy => _activeBank.darkCard;
  static Color get accentColor => _activeBank.accentColor;
  static Color get brandGlow => _activeBank.glowColor;

  static const Color successGreen = Color(0xFF00D09C);
  static const Color expenseRed = Color(0xFFFF4842);
  static const Color warningAmber = Color(0xFFFFAB00);

  // Background and surfaces
  static Color get backgroundLight => _activeBank.lightBackground;
  static Color get cardLight => _activeBank.lightCard;
  static const Color textMainLight = Color(0xFF16181F);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static Color get borderLight => _activeBank.lightBorder;

  static Color get backgroundDark => _activeBank.darkBackground;
  static Color get cardDark => _activeBank.darkCard;
  static const Color textMainDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static Color get borderDark => _activeBank.darkBorder;

  // Gradients
  static LinearGradient get balanceGradientLight => _activeBank.cardGradient;
  static LinearGradient get balanceGradientDark => _activeBank.cardGradient;
}
