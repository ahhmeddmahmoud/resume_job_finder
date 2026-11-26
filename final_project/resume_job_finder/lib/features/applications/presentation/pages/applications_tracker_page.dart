import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_primary_button.dart';
import '../../cubit/applications_cubit.dart';
import '../../models/job_application_model.dart';

/// 17 — Applications Tracker screen.
class ApplicationsTrackerPage extends StatelessWidget {
  const ApplicationsTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tr('طلبات التوظيف', 'My Applications')),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ApplicationsCubit, ApplicationsState>(
          builder: (context, state) {
            if (state.status == ApplicationsStateStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == ApplicationsStateStatus.error &&
                state.applications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(strings.tr(
                        'تعذر تحميل طلبات التوظيف.',
                        'Could not load applications.',
                      )),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => context
                            .read<ApplicationsCubit>()
                            .loadApplications(),
                        child: Text(strings.tr('إعادة المحاولة', 'Try Again')),
                      ),
                    ],
                  ),
                ),
              );
            }

            final all = state.applications;
            final interviewOrAccepted = all
                .where(
                  (a) =>
                      a.status == ApplicationStatus.interview ||
                      a.status == ApplicationStatus.accepted,
                )
                .length;
            final underReview = all
                .where((a) => a.status == ApplicationStatus.underReview)
                .length;
            final filtered = state.filteredApplications;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TrackerStatCard(
                          value: '${all.length}',
                          label: strings.tr('إجمالي الطلبات', 'Total'),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TrackerStatCard(
                          value: '$interviewOrAccepted',
                          label: strings.tr('مقابلة / مقبول', 'Interview'),
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TrackerStatCard(
                          value: '$underReview',
                          label: strings.tr('قيد المراجعة', 'In Review'),
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsetsDirectional.only(
                    start: 20,
                    end: 20,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text(strings.tr('الكل', 'All')),
                          selected: state.selectedFilter == null,
                          onSelected: (_) =>
                              context.read<ApplicationsCubit>().setFilter(null),
                        ),
                      ),
                      ...[
                        ApplicationStatus.applied,
                        ApplicationStatus.underReview,
                        ApplicationStatus.interview,
                      ].map(
                        (status) => Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(
                              status.localizedLabel(isArabic: strings.isArabic),
                            ),
                            selected: state.selectedFilter == status,
                            onSelected: (_) => context
                                .read<ApplicationsCubit>()
                                .setFilter(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color:
                                      AppColors.primary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  strings.tr(
                                    'لا توجد طلبات توظيف بعد',
                                    'No Applications Yet',
                                  ),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GradientPrimaryButton(
                                  label: strings.tr(
                                    'استكشاف الوظائف',
                                    'Explore Jobs',
                                  ),
                                  onPressed: () => context.go(AppRoutes.jobs),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 112),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final app = filtered[index];
                            final localDate = app.appliedAt.toLocal();
                            final dateLabel =
                                '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => context.push(
                                  AppRoutes.applicationDetails,
                                  extra: app,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.softBlue(context),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.work_outline_rounded,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              app.jobTitle.isNotEmpty
                                                  ? app.jobTitle
                                                  : strings.tr(
                                                      'وظيفة مرشحة',
                                                      'Matched Job',
                                                    ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            if (app.companyType.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                app.companyType,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: theme
                                                      .colorScheme.onSurface
                                                      .withValues(alpha: 0.72),
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 4),
                                            Text(
                                              strings.tr(
                                                'تاريخ التقديم: $dateLabel',
                                                'Applied: $dateLabel',
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                color: theme
                                                    .colorScheme.onSurface
                                                    .withValues(alpha: 0.58),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.softBlue(context),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          app.status.localizedLabel(
                                            isArabic: strings.isArabic,
                                          ),
                                          style: TextStyle(
                                            color:
                                                AppColors.softBlueFg(context),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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

class _TrackerStatCard extends StatelessWidget {
  const _TrackerStatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
