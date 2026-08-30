import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/colors.dart';
import '../providers/security_providers.dart';
import '../widgets/pin_setup_modal.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  void _openSetPinModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const PinSetupModal(),
    );
  }

  Future<void> _verifyCurrentPinThen(VoidCallback onSuccess) async {
    final tr = ref.read(translationsProvider);
    final controller = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(tr('sec_enter_current_pin')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: InputDecoration(
                    hintText: '4-digit PIN',
                    errorText: errorText,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(tr('common_cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  final valid = await ref.read(securityProvider.notifier).verifyAndUnlock(controller.text);
                  if (valid) {
                    if (ctx.mounted) Navigator.pop(ctx);
                    onSuccess();
                  } else {
                    setDialogState(() {
                      errorText = 'Incorrect PIN';
                    });
                  }
                },
                child: Text(ref.read(translationsProvider)('common_confirm')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onChangePin() {
    _verifyCurrentPinThen(() {
      _openSetPinModal();
    });
  }

  void _onRemovePin() {
    _verifyCurrentPinThen(() async {
      await ref.read(securityProvider.notifier).removePin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(translationsProvider)('sec_pin_removed'))),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secState = ref.watch(securityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('sec_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            elevation: 0,
            color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.primaryBlue.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          secState.isPinSet ? tr('sec_status_enabled') : tr('sec_status_disabled'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          secState.isPinSet
                              ? 'Apna Batwa requires authentication to access your data.'
                              : 'Set a 4-digit PIN to prevent unauthorized access.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // PIN Management Section
          Text(
            'PIN SECURITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                if (!secState.isPinSet)
                  ListTile(
                    leading: const Icon(Icons.pin_rounded, color: AppColors.primaryBlue),
                    title: Text(tr('sec_set_pin')),
                    subtitle: Text(tr('sec_create_pin_sub')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _openSetPinModal,
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.edit_rounded, color: AppColors.primaryBlue),
                    title: Text(tr('sec_change_pin')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _onChangePin,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.expenseRed),
                    title: Text(
                      tr('sec_remove_pin'),
                      style: const TextStyle(color: AppColors.expenseRed),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.expenseRed),
                    onTap: _onRemovePin,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Biometrics Section (if PIN set)
          if (secState.isPinSet) ...[
            Text(
              'BIOMETRICS & AUTO-LOCK',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.primaryBlue),
                    title: Text(tr('sec_biometrics')),
                    subtitle: Text(
                      secState.isBiometricSupported
                          ? 'Use Fingerprint or Face ID'
                          : 'Biometrics not available on this device',
                    ),
                    value: secState.isBiometricEnabled,
                    onChanged: secState.isBiometricSupported
                        ? (val) async {
                            await ref.read(securityProvider.notifier).setBiometricEnabled(val);
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined, color: AppColors.primaryBlue),
                    title: Text(tr('sec_auto_lock')),
                    subtitle: Text('Lock app after: ${secState.autoLockDuration}'),
                    trailing: DropdownButton<String>(
                      value: secState.autoLockDuration,
                      underline: const SizedBox.shrink(),
                      items: ['Immediately', 'After 1 minute', 'After 5 minutes', 'Never']
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(securityProvider.notifier).setAutoLockDuration(val);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
