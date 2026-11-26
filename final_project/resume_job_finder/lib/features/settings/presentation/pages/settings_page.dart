import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/settings/app_settings_cubit.dart';
import '../../../../core/settings/app_settings_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../../../core/widgets/section_tile_card.dart';
import '../../../auth/cubit/auth_cubit.dart';

/// 21 — Settings screen (Theme, Language, Notifications, Privacy, Password, Sign Out).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppHeaderBar(title: strings.tr('الإعدادات', 'Settings')),
      body: SafeArea(
        child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
          builder: (context, settings) {
            final isDark = settings.themeMode == ThemeMode.dark;
            final isArabic = settings.locale.languageCode == 'ar';

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    strings.tr('المظهر', 'Appearance'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: SwitchListTile(
                      secondary: const Icon(
                        Icons.dark_mode_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        strings.tr('وضع العرض', 'Display Mode'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        isDark
                            ? strings.tr('داكن', 'Dark')
                            : strings.tr('فاتح', 'Light'),
                      ),
                      value: isDark,
                      onChanged: (_) =>
                          context.read<AppSettingsCubit>().toggleTheme(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    strings.tr('اللغة', 'Language'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.language_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        strings.tr('لغة التطبيق', 'App Language'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(isArabic ? 'العربية' : 'English'),
                      trailing: FilledButton.tonal(
                        onPressed: () =>
                            context.read<AppSettingsCubit>().toggleLanguage(),
                        child: Text(isArabic ? 'English' : 'العربية'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    strings.tr('التفضيلات', 'Preferences'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SectionTileCard(
                    icon: Icons.shield_outlined,
                    title: strings.tr(
                      'الخصوصية والأمان',
                      'Privacy & Security',
                    ),
                    subtitle: strings.tr(
                      'إدارة بياناتك وحماية الحساب',
                      'Manage your data and account protection',
                    ),
                    onTap: () => context.push(AppRoutes.privacySecurity),
                  ),
                  SectionTileCard(
                    icon: Icons.lock_outline_rounded,
                    title: strings.tr('تغيير كلمة المرور', 'Change Password'),
                    subtitle: strings.tr(
                      'تحديث كلمة مرور الحساب',
                      'Update your account password',
                    ),
                    onTap: () => context.push(AppRoutes.resetPassword),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      await context.read<AuthCubit>().signOut();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
                    child: Text(
                      strings.tr('تسجيل الخروج', 'Sign Out'),
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
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
