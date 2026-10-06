import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../data/local/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isLoading = false;

  Future<void> _handleCreateBackup() async {
    setState(() => _isLoading = true);
    final db = ref.read(databaseProvider);
    final result = await BackupService.instance.createBackup(db);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? AppColors.successGreen : AppColors.expenseRed,
        ),
      );
    }
  }

  Future<void> _handleRestoreBackup() async {
    final tr = ref.read(translationsProvider);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('backup_restore_dialog_title')),
        content: Text(tr('backup_restore_dialog_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('common_cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('backup_erase_confirm_btn'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final db = ref.read(databaseProvider);
    final result = await BackupService.instance.restoreBackup(db);
    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(result.success ? 'Restore Complete' : 'Restore Failed'),
          content: Text(result.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('common_ok')),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('backup_title')),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(tr('backup_processing')),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Banner
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
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_sync_outlined, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('backup_header_title'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Keep your financial data safe. Export backups to your device or cloud storage, and restore anytime.',
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
                const SizedBox(height: 24),

                // Card 1: Create Backup
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.upload_file_rounded, color: AppColors.successGreen),
                            const SizedBox(width: 10),
                            Text(
                              tr('backup_create_title'),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Export all transactions, Khata records, budgets, and savings goals into a JSON file.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.share_rounded),
                            label: Text(tr('backup_create_btn')),
                            onPressed: _handleCreateBackup,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 2: Restore Backup
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.download_for_offline_rounded, color: AppColors.warningAmber),
                            const SizedBox(width: 10),
                            Text(
                              tr('backup_restore_title'),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select an Apna Batwa JSON backup file to overwrite current app data with restored records.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.warningAmber,
                              side: const BorderSide(color: AppColors.warningAmber),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.file_open_outlined),
                            label: Text(tr('backup_restore_btn')),
                            onPressed: _handleRestoreBackup,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
