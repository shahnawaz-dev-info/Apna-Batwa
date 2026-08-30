import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class WhatsNewModal extends StatelessWidget {
  final String version;
  final VoidCallback onDismiss;

  const WhatsNewModal({
    super.key,
    required this.version,
    required this.onDismiss,
  });

  static Future<void> show(BuildContext context, {required String version, required VoidCallback onDismiss}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WhatsNewModal(version: version, onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final highlights = const [
      WhatsNewHighlight(
        icon: Icons.analytics_outlined,
        title: 'Advanced Analytics & Insights',
        subtitle: 'Spending trends, category donut breakdown, day-of-week patterns, savings rate, and predictive moving-average projections.',
      ),
      WhatsNewHighlight(
        icon: Icons.chat_outlined,
        title: 'WhatsApp Reminders for Khata',
        subtitle: 'Send pre-filled payment reminders directly to your contacts via WhatsApp with one tap.',
      ),
      WhatsNewHighlight(
        icon: Icons.brightness_medium_outlined,
        title: 'Dark / Light Mode Toggle',
        subtitle: 'Switch seamlessly between Light and Dark themes anytime from the app bar or More screen.',
      ),
      WhatsNewHighlight(
        icon: Icons.auto_awesome_outlined,
        title: 'UX Polish & App Improvements',
        subtitle: 'Friendly empty states, app exit confirmation, currency consistency, and dynamic app info.',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars, color: AppColors.primaryBlue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What's New in Version $version",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Apna Batwa V1.1 Feature Update',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: highlights.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = highlights[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, color: AppColors.primaryBlue, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDismiss();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it! 🎉',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WhatsNewHighlight {
  final IconData icon;
  final String title;
  final String subtitle;

  const WhatsNewHighlight({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
