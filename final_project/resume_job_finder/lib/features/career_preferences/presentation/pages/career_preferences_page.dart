import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../../../core/widgets/app_status_banner.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_primary_button.dart';
import '../../../../core/widgets/settings_quick_actions.dart';
import '../../cubit/career_preferences_cubit.dart';
import '../../cubit/career_preferences_state.dart';
import '../widgets/experience_years_stepper.dart';

class CareerPreferencesPage extends StatelessWidget {
  const CareerPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CareerPreferencesCubit>(),
      child: const _CareerPreferencesView(),
    );
  }
}

class _CareerPreferencesView extends StatefulWidget {
  const _CareerPreferencesView();

  @override
  State<_CareerPreferencesView> createState() => _CareerPreferencesViewState();
}

class _CareerPreferencesViewState extends State<_CareerPreferencesView> {
  final _cityController = TextEditingController();
  bool _citySynced = false;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  String _localizeLevel(AppStrings strings, String level) {
    return switch (level) {
      'مبتدئ' => strings.tr('مبتدئ', 'Entry / Junior'),
      'متوسط' => strings.tr('متوسط', 'Mid-Level'),
      'متقدم' => strings.tr('متقدم', 'Senior'),
      _ => level,
    };
  }

  String _localizeWorkType(AppStrings strings, String type) {
    return switch (type) {
      'عن بعد' => strings.tr('عن بعد', 'Remote'),
      'في المكتب' => strings.tr('في المكتب', 'On-site'),
      'هجين' => strings.tr('هجين', 'Hybrid'),
      _ => type,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return BlocConsumer<CareerPreferencesCubit, CareerPreferencesState>(
      listener: (context, state) {
        if (!_citySynced && state.preferredCity.isNotEmpty) {
          _cityController.text = state.preferredCity;
          _citySynced = true;
        }
        if (state.status == CareerPreferencesStatus.saved) {
          context.go(AppRoutes.home);
        }
      },
      builder: (context, state) {
        final cubit = context.read<CareerPreferencesCubit>();
        if (!_citySynced && _cityController.text.isEmpty) {
          _cityController.text = strings.tr('القاهرة', 'Cairo');
        }

        return Scaffold(
          appBar: AppHeaderBar(
            title: strings.preferencesTitle,
            trailingAction: const SettingsQuickActions(),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    strings.preferencesSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.70),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (state.status == CareerPreferencesStatus.error &&
                      state.errorMessage != null) ...[
                    AppStatusBanner(
                      message: state.errorMessage!,
                      type: BannerType.error,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _SectionTitle(strings.trackLabel),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CareerPreferencesCubit.tracks.map((track) {
                      return ChoiceChip(
                        label: Text(track),
                        selected: state.track == track,
                        onSelected: state.isLoading
                            ? null
                            : (_) => cubit.selectTrack(track),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(strings.experienceLevelLabel),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        CareerPreferencesCubit.experienceLevels.map((level) {
                      return ChoiceChip(
                        label: Text(_localizeLevel(strings, level)),
                        selected: state.experienceLevel == level,
                        onSelected: state.isLoading
                            ? null
                            : (_) => cubit.selectExperienceLevel(level),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(strings.experienceYearsLabel),
                  const SizedBox(height: 10),
                  ExperienceYearsStepper(
                    years: state.experienceYears,
                    unitLabel: strings.yearsUnit,
                    enabled: !state.isLoading,
                    onIncrement: cubit.incrementYears,
                    onDecrement: cubit.decrementYears,
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(strings.workTypeLabel),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CareerPreferencesCubit.workTypes.map((type) {
                      return ChoiceChip(
                        label: Text(_localizeWorkType(strings, type)),
                        selected: state.workType == type,
                        onSelected: state.isLoading
                            ? null
                            : (_) => cubit.selectWorkType(type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(strings.preferredCityLabel),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _cityController,
                    label: strings.tr('المدينة', 'City'),
                    hint: strings.tr(
                      'القاهرة، الإسكندرية، عن بعد...',
                      'Cairo, Alexandria, Remote...',
                    ),
                    prefixIcon: Icons.location_on_outlined,
                    enabled: !state.isLoading,
                    onChanged: cubit.selectCity,
                  ),
                  const SizedBox(height: 30),
                  GradientPrimaryButton(
                    label: strings.saveAndContinue,
                    isLoading: state.isLoading,
                    onPressed: () {
                      cubit.selectCity(_cityController.text.trim());
                      cubit.savePreferences(
                        validationError: strings.preferencesValidationError,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
