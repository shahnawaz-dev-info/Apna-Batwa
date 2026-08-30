import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../main_shell.dart';
import '../../../security/presentation/widgets/app_lock_wrapper.dart';
import '../screens/onboarding_screen.dart';

class InitialFlowWrapper extends StatefulWidget {
  const InitialFlowWrapper({super.key});

  @override
  State<InitialFlowWrapper> createState() => _InitialFlowWrapperState();
}

class _InitialFlowWrapperState extends State<InitialFlowWrapper> {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('has_seen_onboarding') ?? false;
      if (mounted) {
        setState(() {
          _hasSeenOnboarding = seen;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasSeenOnboarding) {
      return const OnboardingScreen();
    }

    return const AppLockWrapper(child: MainShell());
  }
}
