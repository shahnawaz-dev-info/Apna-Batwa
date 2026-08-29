import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/wishlist_item.dart';
import '../providers/wishlist_providers.dart';

class AddWishlistModal extends ConsumerStatefulWidget {
  final WishlistItemEntity? existingItem;

  const AddWishlistModal({super.key, this.existingItem});

  static Future<void> show(BuildContext context, {WishlistItemEntity? existingItem}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWishlistModal(existingItem: existingItem),
    );
  }

  @override
  ConsumerState<AddWishlistModal> createState() => _AddWishlistModalState();
}

class _AddWishlistModalState extends ConsumerState<AddWishlistModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
  late WishlistPriority _selectedPriority;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingItem?.name ?? '');
    _priceController = TextEditingController(
      text: widget.existingItem != null ? (widget.existingItem!.priceCents / 100).toStringAsFixed(2) : '',
    );
    _categoryController = TextEditingController(text: widget.existingItem?.category ?? 'General');
    _notesController = TextEditingController(text: widget.existingItem?.notes ?? '');
    _selectedPriority = widget.existingItem?.priority ?? WishlistPriority.medium;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final priceDouble = double.parse(_priceController.text.trim());
    final priceCents = (priceDouble * 100).round();
    final category = _categoryController.text.trim();
    final notes = _notesController.text.trim();

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(wishlistRepositoryProvider);
      if (widget.existingItem != null) {
        final updated = WishlistItemEntity(
          id: widget.existingItem!.id,
          name: name,
          priceCents: priceCents,
          category: category,
          priority: _selectedPriority,
          notes: notes.isEmpty ? null : notes,
          isPurchased: widget.existingItem!.isPurchased,
          createdAt: widget.existingItem!.createdAt,
          purchasedAt: widget.existingItem!.purchasedAt,
        );
        await repo.updateWishlistItem(updated);
      } else {
        await repo.addWishlistItem(
          name: name,
          priceCents: priceCents,
          category: category,
          priority: _selectedPriority,
          notes: notes.isEmpty ? null : notes,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving wishlist item: $e'), backgroundColor: AppColors.expenseRed),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingItem != null;

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
                    isEditing ? 'Edit Wishlist Item' : '+ Add to Wishlist',
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
                  labelText: 'Item Name *',
                  hintText: 'e.g. Wireless Earbuds, Books',
                  prefixIcon: Icon(Icons.favorite_outline),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter item name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Estimated Price (Rs.) *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter estimated price';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  hintText: 'e.g. Tech, Electronics, Books, Clothes',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter category' : null,
              ),
              const SizedBox(height: 16),
              const Text('Priority Level *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: WishlistPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  Color priorityColor;
                  switch (priority) {
                    case WishlistPriority.high:
                      priorityColor = AppColors.expenseRed;
                      break;
                    case WishlistPriority.medium:
                      priorityColor = AppColors.warningAmber;
                      break;
                    case WishlistPriority.low:
                      priorityColor = AppColors.primaryBlue;
                      break;
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          priority.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : priorityColor,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: priorityColor,
                        backgroundColor: priorityColor.withOpacity(0.12),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedPriority = priority);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Link, brand, or store details',
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
                          isEditing ? 'Save Changes' : 'Add to Wishlist',
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
