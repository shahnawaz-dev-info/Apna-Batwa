import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_translations.dart';
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

  Future<void> _submit(String Function(String) tr) async {
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
        SnackBar(content: Text('${tr("common_error")}: $e'), backgroundColor: AppColors.expenseRed),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = ref.watch(translationsProvider);
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
                    isEditing ? tr('wishlist_edit_modal_title') : tr('wishlist_add_modal_title'),
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
                decoration: InputDecoration(
                  labelText: tr('wishlist_item_name_label'),
                  hintText: 'e.g. Wireless Earbuds, Books',
                  prefixIcon: const Icon(Icons.favorite_outline),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter item name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: tr('wishlist_est_price_label'),
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
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
                decoration: InputDecoration(
                  labelText: tr('wishlist_category_label'),
                  hintText: 'e.g. Electronics, Books, Fashion',
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<WishlistPriority>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  labelText: tr('wishlist_priority_label'),
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                items: WishlistPriority.values.map((p) {
                  String label = tr('wishlist_priority_medium');
                  if (p == WishlistPriority.high) label = tr('wishlist_priority_high');
                  if (p == WishlistPriority.low) label = tr('wishlist_priority_low');
                  return DropdownMenuItem(value: p, child: Text(label));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPriority = val);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: tr('wishlist_notes_label'),
                  hintText: 'e.g. Wait for sale, link to store',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
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
                  onPressed: _isSaving ? null : () => _submit(tr),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          isEditing ? tr('wishlist_update_item') : tr('wishlist_save_item'),
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
