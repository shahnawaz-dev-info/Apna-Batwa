import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/borrowed_record.dart';
import '../../domain/entities/lent_record.dart';
import '../../domain/entities/person.dart';
import '../providers/khata_providers.dart';
import 'add_person_modal.dart';
import '../../../../core/services/notification_service.dart';

class AddBorrowedLentModal extends ConsumerStatefulWidget {
  final bool isBorrowed;
  final BorrowedRecordEntity? existingBorrowed;
  final LentRecordEntity? existingLent;

  const AddBorrowedLentModal({
    super.key,
    required this.isBorrowed,
    this.existingBorrowed,
    this.existingLent,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isBorrowed,
    BorrowedRecordEntity? existingBorrowed,
    LentRecordEntity? existingLent,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddBorrowedLentModal(
        isBorrowed: isBorrowed,
        existingBorrowed: existingBorrowed,
        existingLent: existingLent,
      ),
    );
  }

  @override
  ConsumerState<AddBorrowedLentModal> createState() => _AddBorrowedLentModalState();
}

class _AddBorrowedLentModalState extends ConsumerState<AddBorrowedLentModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  PersonEntity? _selectedPerson;
  DateTime _selectedDate = DateTime.now();
  DateTime? _reminderDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingBorrowed != null) {
      _amountController.text =
          (widget.existingBorrowed!.totalAmountCents / 100).toStringAsFixed(2);
      _noteController.text = widget.existingBorrowed!.note ?? '';
      _selectedDate = widget.existingBorrowed!.date;
    } else if (widget.existingLent != null) {
      _amountController.text =
          (widget.existingLent!.totalAmountCents / 100).toStringAsFixed(2);
      _noteController.text = widget.existingLent!.note ?? '';
      _selectedDate = widget.existingLent!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit(String Function(String) tr) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('khata_err_select_person')),
          backgroundColor: AppColors.expenseRed,
        ),
      );
      return;
    }

    final doubleAmount = double.parse(_amountController.text.trim());
    final amountCents = (doubleAmount * 100).round();
    final note = _noteController.text.trim();

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(khataRepositoryProvider);
      int recordId = 0;
      if (widget.isBorrowed) {
        if (widget.existingBorrowed == null) {
          recordId = await repo.addBorrowedRecord(
            personId: _selectedPerson!.id,
            totalAmountCents: amountCents,
            date: _selectedDate,
            note: note.isEmpty ? null : note,
          );
        } else {
          recordId = widget.existingBorrowed!.id;
          await repo.updateBorrowedRecord(
            id: widget.existingBorrowed!.id,
            personId: _selectedPerson!.id,
            totalAmountCents: amountCents,
            date: _selectedDate,
            note: note.isEmpty ? null : note,
          );
        }
      } else {
        if (widget.existingLent == null) {
          recordId = await repo.addLentRecord(
            personId: _selectedPerson!.id,
            totalAmountCents: amountCents,
            date: _selectedDate,
            note: note.isEmpty ? null : note,
          );
        } else {
          recordId = widget.existingLent!.id;
          await repo.updateLentRecord(
            id: widget.existingLent!.id,
            personId: _selectedPerson!.id,
            totalAmountCents: amountCents,
            date: _selectedDate,
            note: note.isEmpty ? null : note,
          );
        }
      }

      if (_reminderDate != null && _selectedPerson != null) {
        await NotificationService.instance.scheduleKhataReminder(
          notificationId: recordId * 10 + (widget.isBorrowed ? 1 : 2),
          personName: _selectedPerson!.name,
          amountCents: amountCents,
          isBorrowed: widget.isBorrowed,
          reminderDate: _reminderDate!,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr("common_error")}: $e'),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = ref.watch(translationsProvider);
    final personsAsync = ref.watch(watchAllPersonsProvider);

    final titleText = widget.isBorrowed
        ? (widget.existingBorrowed == null ? tr('khata_add_borrowed_title') : tr('khata_edit_borrowed_title'))
        : (widget.existingLent == null ? tr('khata_add_lent_title') : tr('khata_edit_lent_title'));

    final primaryColor = widget.isBorrowed ? AppColors.warningAmber : AppColors.primaryBlue;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    titleText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Person Selection & Inline Add
              personsAsync.when(
                data: (persons) {
                  if (_selectedPerson == null && persons.isNotEmpty) {
                    final targetId = widget.existingBorrowed?.personId ?? widget.existingLent?.personId;
                    if (targetId != null) {
                      _selectedPerson = persons.firstWhere(
                        (p) => p.id == targetId,
                        orElse: () => persons.first,
                      );
                    }
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<PersonEntity>(
                          value: persons.contains(_selectedPerson) ? _selectedPerson : null,
                          decoration: InputDecoration(
                            labelText: tr('khata_person_label'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          hint: Text(tr('khata_select_person')),
                          items: persons
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setState(() => _selectedPerson = val),
                          validator: (val) => val == null ? tr('khata_select_person') : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () async {
                          final newPerson = await AddPersonModal.show(context);
                          if (newPerson != null) {
                            setState(() => _selectedPerson = newPerson);
                          }
                        },
                        icon: const Icon(Icons.person_add_alt_1),
                        tooltip: tr('khata_add_new_person_tooltip'),
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('${tr("common_error")}: $err'),
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: tr('khata_amount_label'),
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter amount';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid positive amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: tr('khata_date_label'),
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormatters.formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: tr('khata_note_label'),
                  hintText: 'e.g. Hostel rent share, Lunch bill',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Repayment Reminder Picker
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _reminderDate ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && mounted) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _reminderDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: tr('khata_remind_me_label'),
                    prefixIcon: const Icon(Icons.alarm),
                    suffixIcon: _reminderDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _reminderDate = null),
                          )
                        : null,
                  ),
                  child: Text(
                    _reminderDate != null
                        ? DateFormatters.formatDateTime(_reminderDate!)
                        : tr('khata_tap_set_reminder'),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaving ? null : () => _submit(tr),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          widget.existingBorrowed != null || widget.existingLent != null
                              ? tr('khata_update_entry')
                              : tr('khata_save_entry'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
