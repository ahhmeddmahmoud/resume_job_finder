import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/widgets/app_status_banner.dart';
import '../../../../core/widgets/settings_quick_actions.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../career_preferences/models/career_preferences_model.dart';

/// Temporary Home placeholder for verifying the pre-Home flow.
class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final storage = sl<LocalStorageService>();
    final prefsJson = storage.getCareerPreferencesJson();
    final prefs =
        prefsJson != null ? CareerPreferencesModel.fromJson(prefsJson) : null;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.loggedOut) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.homePlaceholderTitle),
          actions: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SettingsQuickActions(),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppStatusBanner(
                  message: strings.homePlaceholderSubtitle,
                  type: BannerType.success,
                ),
                const SizedBox(height: 20),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authState.user?.name ??
                                  storage.userName ??
                                  'DEPI User',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authState.user?.email ?? storage.userEmail ?? '-',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.68),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: prefs == null
                        ? Text(strings.noPreferencesSaved)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PrefRow(
                                label: strings.trackLabel,
                                value: prefs.track,
                              ),
                              _PrefRow(
                                label: strings.experienceLevelLabel,
                                value: prefs.experienceLevel,
                              ),
                              _PrefRow(
                                label: strings.experienceYearsLabel,
                                value:
                                    '${prefs.experienceYears} ${strings.yearsUnit}',
                              ),
                              _PrefRow(
                                label: strings.workTypeLabel,
                                value: prefs.workType,
                              ),
                              _PrefRow(
                                label: strings.preferredCityLabel,
                                value: prefs.preferredCity,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.careerPreferences),
                  icon: const Icon(Icons.tune_rounded),
                  label: Text(strings.editPreferences),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await context.read<AuthCubit>().logout();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(strings.logout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  const _PrefRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
