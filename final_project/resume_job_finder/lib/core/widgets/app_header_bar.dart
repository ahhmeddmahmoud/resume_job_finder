import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Clean centered header with circular back button and optional action.
class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const AppHeaderBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.trailingAction,
  });

  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailingAction;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = showBack && (onBack != null || context.canPop());

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      leading: canPop
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onBack ?? () => context.pop(),
                child: CircleAvatar(
                  backgroundColor: AppColors.softNeutral(context),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            )
          : null,
      actions: trailingAction != null
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: trailingAction!,
              ),
            ]
          : null,
    );
  }
}
