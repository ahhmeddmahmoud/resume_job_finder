import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

enum BannerType { error, success, info }

/// Inline status banner for displaying error, success, or info feedback.
class AppStatusBanner extends StatelessWidget {
  const AppStatusBanner({
    super.key,
    required this.message,
    this.type = BannerType.error,
  });

  final String message;
  final BannerType type;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (type) {
      BannerType.error => (AppColors.error, Icons.error_outline_rounded),
      BannerType.success => (
          AppColors.success,
          Icons.check_circle_outline_rounded
        ),
      BannerType.info => (AppColors.primary, Icons.info_outline_rounded),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
