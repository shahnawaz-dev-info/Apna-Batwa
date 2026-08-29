import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../providers/security_providers.dart';

class PinSetupModal extends ConsumerStatefulWidget {
  const PinSetupModal({super.key});

  @override
  ConsumerState<PinSetupModal> createState() => _PinSetupModalState();
}

class _PinSetupModalState extends ConsumerState<PinSetupModal> {
  int _step = 1; // 1 = Enter PIN, 2 = Confirm PIN
  String _firstPin = '';
  String _currentPin = '';
  String? _errorMessage;

  void _onDigitPressed(String digit) {
    if (_currentPin.length >= 4) return;
    setState(() {
      _errorMessage = null;
      _currentPin += digit;
    });

    if (_currentPin.length == 4) {
      _processStep();
    }
  }

  void _onBackspace() {
    if (_currentPin.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _currentPin = _currentPin.substring(0, _currentPin.length - 1);
    });
  }

  void _processStep() {
    if (_step == 1) {
      setState(() {
        _firstPin = _currentPin;
        _currentPin = '';
        _step = 2;
      });
    } else if (_step == 2) {
      if (_currentPin == _firstPin) {
        _savePin();
      } else {
        setState(() {
          _errorMessage = 'PINs do not match. Try again.';
          _firstPin = '';
          _currentPin = '';
          _step = 1;
        });
      }
    }
  }

  Future<void> _savePin() async {
    await ref.read(securityProvider.notifier).setPin(_firstPin);
    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN has been successfully set.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _step == 1 ? 'Set New 4-Digit PIN' : 'Confirm Your 4-Digit PIN',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _step == 1
                ? 'Enter a 4-digit code to protect Apna Batwa'
                : 'Re-enter the same 4-digit code to confirm',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),

          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final filled = index < _currentPin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? AppColors.primaryBlue : (isDark ? Colors.white24 : Colors.black12),
                  border: Border.all(
                    color: filled ? AppColors.primaryBlue : (isDark ? Colors.white38 : Colors.black26),
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Error Message
          SizedBox(
            height: 20,
            child: _errorMessage != null
                ? Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.expenseRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Keypad
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.6,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              if (index == 9) {
                return const SizedBox.shrink();
              } else if (index == 10) {
                return _buildKeypadButton('0', isDark);
              } else if (index == 11) {
                return IconButton(
                  icon: const Icon(Icons.backspace_outlined, size: 22),
                  onPressed: _onBackspace,
                );
              } else {
                return _buildKeypadButton('${index + 1}', isDark);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String number, bool isDark) {
    return InkWell(
      onTap: () => _onDigitPressed(number),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
