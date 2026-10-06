import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/theme_providers.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';
import 'features/onboarding/presentation/widgets/initial_flow_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(
    const ProviderScope(
      child: ApnaBatwaApp(),
    ),
  );
}

class ApnaBatwaApp extends ConsumerWidget {
  const ApnaBatwaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final bankConfig = ref.watch(activeBankConfigProvider);
    
    // Sync AppColors dynamic token state with active bank theme
    AppColors.setBankConfig(bankConfig);

    return MaterialApp(
      title: 'Apna Batwa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(Brightness.light, bankConfig),
      darkTheme: AppTheme.buildTheme(Brightness.dark, bankConfig),
      themeMode: themeMode,
      home: const InitialFlowWrapper(),
    );
  }
}
