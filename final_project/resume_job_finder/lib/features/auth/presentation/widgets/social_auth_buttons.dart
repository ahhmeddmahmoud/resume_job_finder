import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';

/// UI-ready Google button for future Firebase integration.
class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    required this.onGooglePressed,
    this.enabled = true,
  });

  final VoidCallback onGooglePressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final dividerColor = Theme.of(context).dividerColor.withValues(alpha: 0.4);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                strings.orContinueWith,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(child: Divider(color: dividerColor)),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: enabled ? onGooglePressed : null,
          icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
          label: Text(strings.continueWithGoogle),
        ),
      ],
    );
  }
}
