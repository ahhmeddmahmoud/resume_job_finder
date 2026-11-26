import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Animated circular progress ring showing `XX%` and semantic match color.
class CircularMatchIndicator extends StatelessWidget {
  const CircularMatchIndicator({
    super.key,
    required this.percentage,
    this.size = 84,
    this.strokeWidth = 8,
    this.subtitle,
  });

  final int percentage;
  final double size;
  final double strokeWidth;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final clamped = percentage.clamp(0, 100);
    final color = AppColors.matchColor(clamped);
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: '$clamped% ${subtitle ?? ''}'.trim(),
      child: SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: reduceMotion ? clamped / 100 : 0,
            end: clamped / 100,
          ),
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  strokeCap: StrokeCap.round,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.16),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$clamped%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: color,
                          fontSize: size >= 80 ? 20 : 15,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
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
    );
  }
}
