import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/app_strings.dart';
import '../settings/app_settings_cubit.dart';
import '../settings/app_settings_state.dart';

/// Quick language (AR/EN) and theme (Light/Dark) toggle buttons.
class SettingsQuickActions extends StatelessWidget {
  const SettingsQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () =>
                  context.read<AppSettingsCubit>().toggleLanguage(),
              child: Text(
                strings.switchLanguage,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: state.isDarkMode ? 'Light Mode' : 'Dark Mode',
              onPressed: () => context.read<AppSettingsCubit>().toggleTheme(),
              icon: Icon(
                state.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          ],
        );
      },
    );
  }
}
