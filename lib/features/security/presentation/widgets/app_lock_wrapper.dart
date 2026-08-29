import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_providers.dart';
import '../screens/pin_lock_screen.dart';

class AppLockWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const AppLockWrapper({super.key, required this.child});

  @override
  ConsumerState<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends ConsumerState<AppLockWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(securityProvider.notifier).handleAppLifecycle(state);
  }

  @override
  Widget build(BuildContext context) {
    final secState = ref.watch(securityProvider);

    return Stack(
      children: [
        widget.child,
        if (secState.isLocked)
          const Positioned.fill(
            child: PinLockScreen(),
          ),
      ],
    );
  }
}
