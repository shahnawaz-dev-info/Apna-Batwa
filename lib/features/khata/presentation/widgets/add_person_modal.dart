import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../providers/khata_providers.dart';
import '../../domain/entities/person.dart';

class AddPersonModal extends ConsumerStatefulWidget {
  final PersonEntity? existingPerson;

  const AddPersonModal({super.key, this.existingPerson});

  static Future<PersonEntity?> show(BuildContext context, {PersonEntity? existingPerson}) {
    return showModalBottomSheet<PersonEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPersonModal(existingPerson: existingPerson),
    );
  }

  @override
  ConsumerState<AddPersonModal> createState() => _AddPersonModalState();
}

class _AddPersonModalState extends ConsumerState<AddPersonModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingPerson != null) {
      _nameController.text = widget.existingPerson!.name;
      _phoneController.text = widget.existingPerson!.phoneNumber ?? '';
      _noteController.text = widget.existingPerson!.note ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final note = _noteController.text.trim();

    // Check duplicate name case-insensitive
    final repo = ref.read(khataRepositoryProvider);
    final existingList = await repo.getAllPersons();
    final isDuplicate = existingList.any(
      (p) => p.name.toLowerCase() == name.toLowerCase() && p.id != widget.existingPerson?.id,
    );

    if (isDuplicate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A person named "$name" already exists.'),
          backgroundColor: AppColors.expenseRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (widget.existingPerson == null) {
        final newId = await repo.addPerson(
          name: name,
          phoneNumber: phone.isEmpty ? null : phone,
          note: note.isEmpty ? null : note,
        );
        final createdPerson = PersonEntity(
          id: newId,
          name: name,
          phoneNumber: phone.isEmpty ? null : phone,
          note: note.isEmpty ? null : note,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        if (!mounted) return;
        Navigator.pop(context, createdPerson);
      } else {
        final updatedPerson = PersonEntity(
          id: widget.existingPerson!.id,
          name: name,
          phoneNumber: phone.isEmpty ? null : phone,
          note: note.isEmpty ? null : note,
          createdAt: widget.existingPerson!.createdAt,
          updatedAt: DateTime.now(),
        );
        await repo.updatePerson(updatedPerson);
        if (!mounted) return;
        Navigator.pop(context, updatedPerson);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving person: $e'),
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
                    widget.existingPerson == null ? 'Add New Person' : 'Edit Person',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Person Name *',
                  hintText: 'e.g. Ali, Ahmed, Roommate',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  hintText: 'e.g. 03001234567 or +923001234567',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'e.g. Cousin, Hostel Room 204',
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
                          widget.existingPerson == null ? 'Save Person' : 'Update Person',
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
