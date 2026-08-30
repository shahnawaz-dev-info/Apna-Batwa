import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/person.dart';
import '../providers/khata_providers.dart';
import '../widgets/add_person_modal.dart';

class ManagePersonsScreen extends ConsumerWidget {
  const ManagePersonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final personsAsync = ref.watch(watchAllPersonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('khata_manage_people')),
      ),
      body: personsAsync.when(
        data: (persons) {
          if (persons.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr('khata_no_people_title'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr('khata_no_people_sub'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: persons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final person = persons[index];
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                    child: Text(
                      person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  title: Text(
                    person.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: (person.phoneNumber != null && person.phoneNumber!.isNotEmpty) ||
                          (person.note != null && person.note!.isNotEmpty)
                      ? Text(
                          '${person.phoneNumber != null && person.phoneNumber!.isNotEmpty ? "📞 ${person.phoneNumber}" : ""}${person.phoneNumber != null && person.phoneNumber!.isNotEmpty && person.note != null && person.note!.isNotEmpty ? " • " : ""}${person.note ?? ""}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => AddPersonModal.show(context, existingPerson: person),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed, size: 20),
                        onPressed: () => _confirmDelete(context, ref, person),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddPersonModal.show(context),
        icon: const Icon(Icons.add),
        label: Text(tr('khata_add_person_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, PersonEntity person) {
    final tr = ref.read(translationsProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('khata_delete_person_title')),
        content: Text(tr('khata_delete_person_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('common_cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final repo = ref.read(khataRepositoryProvider);
                await repo.deletePerson(person.id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tr('khata_delete_person_error')),
                      backgroundColor: AppColors.expenseRed,
                    ),
                  );
                }
              }
            },
            child: Text(tr('common_delete')),
          ),
        ],
      ),
    );
  }
}
