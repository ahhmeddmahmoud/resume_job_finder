import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Pill badge for extracted, matched, or missing skills.
class SkillChipBadge extends StatelessWidget {
  const SkillChipBadge({
    super.key,
    required this.label,
    this.isMatched = false,
    this.isMissing = false,
  });

  final String label;
  final bool isMatched;
  final bool isMissing;

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    final Color bgColor;
    final Color fgColor;

    if (isMissing) {
      bgColor = AppColors.softAmber(context);
      fgColor = themeColors.warning;
    } else if (isMatched) {
      bgColor = AppColors.softGreen(context);
      fgColor = themeColors.success;
    } else {
      bgColor = themeColors.chipBackground;
      fgColor = themeColors.chipForeground;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fgColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (isMatched) ...[
            const SizedBox(width: 4),
            Icon(Icons.check_rounded, size: 14, color: fgColor),
          ],
        ],
      ),
    );
  }
}
