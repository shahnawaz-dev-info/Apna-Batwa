import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/purchase.dart';
import '../providers/wishlist_providers.dart';

class AddPurchaseModal extends ConsumerStatefulWidget {
  final PurchaseEntity? existingPurchase;

  const AddPurchaseModal({super.key, this.existingPurchase});

  static Future<void> show(BuildContext context, {PurchaseEntity? existingPurchase}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPurchaseModal(existingPurchase: existingPurchase),
    );
  }

  @override
  ConsumerState<AddPurchaseModal> createState() => _AddPurchaseModalState();
}

class _AddPurchaseModalState extends ConsumerState<AddPurchaseModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingPurchase?.name ?? '');
    _amountController = TextEditingController(
      text: widget.existingPurchase != null ? (widget.existingPurchase!.amountCents / 100).toStringAsFixed(2) : '',
    );
    _categoryController = TextEditingController(text: widget.existingPurchase?.category ?? 'General');
    _notesController = TextEditingController(text: widget.existingPurchase?.notes ?? '');
    _selectedDate = widget.existingPurchase?.purchaseDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
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

    final name = _nameController.text.trim();
    final amountDouble = double.parse(_amountController.text.trim());
    final amountCents = (amountDouble * 100).round();
    final category = _categoryController.text.trim();
    final notes = _notesController.text.trim();

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(wishlistRepositoryProvider);
      if (widget.existingPurchase != null) {
        final updated = PurchaseEntity(
          id: widget.existingPurchase!.id,
          name: name,
          amountCents: amountCents,
          category: category,
          purchaseDate: _selectedDate,
          linkedWishlistItemId: widget.existingPurchase!.linkedWishlistItemId,
          linkedExpenseId: widget.existingPurchase!.linkedExpenseId,
          notes: notes.isEmpty ? null : notes,
          createdAt: widget.existingPurchase!.createdAt,
        );
        await repo.updatePurchase(updated);
      } else {
        await repo.addPurchase(
          name: name,
          amountCents: amountCents,
          category: category,
          purchaseDate: _selectedDate,
          notes: notes.isEmpty ? null : notes,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase recorded! Expense balance updated.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving purchase: $e'), backgroundColor: AppColors.expenseRed),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingPurchase != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    isEditing ? 'Edit Purchase' : '+ Log Direct Purchase',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item / Purchase Name *',
                  hintText: 'e.g. Groceries, Shoes',
                  prefixIcon: Icon(Icons.shopping_cart_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter purchase name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount Paid (Rs.) *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter amount';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  hintText: 'e.g. Food, Clothing, Electronics',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter category' : null,
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Purchase Date *',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormatters.formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Store name, warranty, receipt info',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEditing ? 'Save Changes' : 'Log Purchase & Expense',
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
