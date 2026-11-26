import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
// Required so CrystalNavigationBar's BottomAppBar finds Flutter Material's Scaffold.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Main 5-tab bottom-navigation shell using [CrystalNavigationBar] inside a
/// standard Flutter Material [Scaffold] so `BottomAppBar` resolves
/// `Scaffold.geometryOf` cleanly.
class MainShellScaffold extends StatelessWidget {
  const MainShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = AppColors.isDark(context);
    final selectedIndex = navigationShell.currentIndex;

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && selectedIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: navigationShell,
        bottomNavigationBar: Builder(
          builder: (scaffoldContext) {
            return SafeArea(
              top: false,
              child: CrystalNavigationBar(
                currentIndex: selectedIndex,
                height: 72,
                borderRadius: 24,
                marginR: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                paddingR: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                itemPadding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 4,
                ),
                showLabels: true,
                enableFloatingNavBar: true,
                selectedItemColor:
                    isDark ? AppColors.primaryDark : AppColors.primary,
                unselectedItemColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                indicatorColor:
                    isDark ? AppColors.primaryDark : AppColors.primary,
                backgroundColor: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.88)
                    : AppColors.lightSurface.withValues(alpha: 0.92),
                outlineBorderColor:
                    isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderWidth: 1,
                boxShadow: isDark
                    ? const []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                onTap: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == selectedIndex,
                  );
                },
                items: [
                  CrystalNavigationBarItem(
                    icon: Icons.home_rounded,
                    unselectedIcon: Icons.home_outlined,
                    label: l10n.tabHome,
                  ),
                  CrystalNavigationBarItem(
                    icon: Icons.work_rounded,
                    unselectedIcon: Icons.work_outline_rounded,
                    label: l10n.tabJobs,
                  ),
                  CrystalNavigationBarItem(
                    icon: Icons.bookmark_rounded,
                    unselectedIcon: Icons.bookmark_border_rounded,
                    label: l10n.tabSaved,
                  ),
                  CrystalNavigationBarItem(
                    icon: Icons.assignment_rounded,
                    unselectedIcon: Icons.assignment_outlined,
                    label: l10n.tabApplications,
                  ),
                  CrystalNavigationBarItem(
                    icon: Icons.person_rounded,
                    unselectedIcon: Icons.person_outline_rounded,
                    label: l10n.tabProfile,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
