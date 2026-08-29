import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/khata_providers.dart';

class AddRepaymentModal extends ConsumerStatefulWidget {
  final String recordType; // 'borrowed' or 'lent'
  final int recordId;
  final int remainingCents;

  const AddRepaymentModal({
    super.key,
    required this.recordType,
    required this.recordId,
    required this.remainingCents,
  });

  static Future<void> show(
    BuildContext context, {
    required String recordType,
    required int recordId,
    required int remainingCents,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddRepaymentModal(
        recordType: recordType,
        recordId: recordId,
        remainingCents: remainingCents,
      ),
    );
  }

  @override
  ConsumerState<AddRepaymentModal> createState() => _AddRepaymentModalState();
}

class _AddRepaymentModalState extends ConsumerState<AddRepaymentModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

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

    final doubleAmount = double.parse(_amountController.text.trim());
    final amountCents = (doubleAmount * 100).round();
    final note = _noteController.text.trim();

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(khataRepositoryProvider);
      await repo.addRepayment(
        recordType: widget.recordType,
        recordId: widget.recordId,
        amountCents: amountCents,
        date: _selectedDate,
        note: note.isEmpty ? null : note,
      );

      final overpaidCents = amountCents - widget.remainingCents;
      if (overpaidCents > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This payment exceeds remaining balance by ${CurrencyFormatter.formatCents(overpaidCents)} — the record will show as overpaid.',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding repayment: $e'),
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
    final isBorrowed = widget.recordType == 'borrowed';
    final actionTitle = isBorrowed ? '+ Log Payment (Money Returned)' : '+ Log Receipt (Money Received)';
    final primaryColor = isBorrowed ? AppColors.successGreen : AppColors.primaryBlue;

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
                    actionTitle,
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
              const SizedBox(height: 8),

              // Remaining Balance Indicator Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Remaining Balance:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      CurrencyFormatter.formatCents(widget.remainingCents),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Amount Field with Overpayment Allowed
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Repayment Amount (Rs.) *',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  suffixIcon: widget.remainingCents > 0
                      ? TextButton(
                          onPressed: () {
                            _amountController.text = (widget.remainingCents / 100).toStringAsFixed(2);
                          },
                          child: const Text('Pay Full'),
                        )
                      : null,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter repayment amount';
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
                  labelText: 'Note (Optional)',
                  hintText: 'e.g. Cash payment, Google Pay',
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
                      : const Text(
                          'Save Repayment',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
