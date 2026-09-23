import 'package:flutter_test/flutter_test.dart';
import 'package:apnabatwa/core/theme/colors.dart';

void main() {
  test('BankThemeConfig has 6 valid themes including default and top Pakistani banks', () {
    expect(BankThemeConfig.allBanks.length, equals(6));
    expect(BankThemeConfig.getConfig(BankThemePreset.sadapay).name, equals('SadaPay'));
    expect(BankThemeConfig.getConfig(BankThemePreset.nayapay).name, equals('NayaPay'));
    expect(BankThemeConfig.getConfig(BankThemePreset.meezan).name, equals('Meezan Bank'));
    expect(BankThemeConfig.getConfig(BankThemePreset.hbl).name, equals('HBL'));
    expect(BankThemeConfig.getConfig(BankThemePreset.ubl).name, equals('UBL'));
    expect(BankThemeConfig.getConfig(BankThemePreset.defaultBatwa).name, equals('Apna Batwa'));
  });
}
