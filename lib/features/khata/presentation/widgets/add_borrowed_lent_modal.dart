import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/borrowed_record.dart';
import '../../domain/entities/lent_record.dart';
import '../../domain/entities/person.dart';
import '../providers/khata_providers.dart';
import 'add_person_modal.dart';

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add a person.'),
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
      if (widget.isBorrowed) {
        if (widget.existingBorrowed == null) {
          await repo.addBorrowedRecord(
            personId: _selectedPerson!.id,
            totalAmountCents: amountCents,
            date: _selectedDate,
            note: note.isEmpty ? null : note,
          );
        } else {
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
          await repo.addLentRecord(
            personId: _selectedPerson!.id,
            totalAmountCents: amountCents,
            date: _selectedDate,
            note: note.isEmpty ? null : note,
          );
        } else {
          await repo.updateLentRecord(
            id: widget.existingLent!.id,
            personId: _selectedPerson!.id,
            totalAmountCents: amountCents,
            date: _selectedDate,
            note: note.isEmpty ? null : note,
          );
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving record: $e'),
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
    final personsAsync = ref.watch(watchAllPersonsProvider);

    final titleText = widget.isBorrowed
        ? (widget.existingBorrowed == null ? '+ Borrow Money (I Owe)' : 'Edit Borrowed Entry')
        : (widget.existingLent == null ? '+ Lend Money (Others Owe Me)' : 'Edit Lent Entry');

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
                  // Set initial selected person if editing or if list loaded
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
                          decoration: const InputDecoration(
                            labelText: 'Person *',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          hint: const Text('Select Person'),
                          items: persons
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setState(() => _selectedPerson = val),
                          validator: (val) => val == null ? 'Select a person' : null,
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
                        tooltip: 'Add New Person',
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading persons: $err'),
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Total Amount (Rs.) *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
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
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormatters.formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note / Reason (Optional)',
                  hintText: 'e.g. Hostel rent share, Lunch bill',
                  prefixIcon: Icon(Icons.note_alt_outlined),
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
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          widget.existingBorrowed != null || widget.existingLent != null
                              ? 'Update Entry'
                              : 'Save Entry',
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
