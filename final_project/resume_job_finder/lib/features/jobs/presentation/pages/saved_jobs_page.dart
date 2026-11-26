import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_primary_button.dart';
import '../../../../core/widgets/skill_chip_badge.dart';
import '../../cubit/saved_jobs_cubit.dart';

/// 15 — Saved Jobs screen.
class SavedJobsPage extends StatelessWidget {
  const SavedJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.tr('الوظائف المحفوظة', 'Saved Jobs'))),
      body: SafeArea(
        child: BlocBuilder<SavedJobsCubit, SavedJobsState>(
          builder: (context, state) {
            if (state.status == SavedJobsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == SavedJobsStatus.error &&
                state.savedJobs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(strings.tr(
                        'تعذر تحميل الوظائف المحفوظة.',
                        'Could not load saved jobs.',
                      )),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            context.read<SavedJobsCubit>().loadSavedJobs(),
                        child: Text(strings.tr('إعادة المحاولة', 'Try Again')),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.savedJobs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 64,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        strings.tr(
                          'لا توجد وظائف محفوظة بعد',
                          'No Saved Jobs Yet',
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.tr(
                          'اضغط على أيقونة الحفظ في أي وظيفة للرجوع إليها لاحقًا.',
                          'Tap the bookmark icon on any job to save it for later.',
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.68),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GradientPrimaryButton(
                        label: strings.tr('استكشاف الوظائف', 'Explore Jobs'),
                        onPressed: () => context.go(AppRoutes.jobs),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
              children: [
                ...state.savedJobs.map((job) {
                  final initial =
                      job.title.isNotEmpty ? job.title[0].toUpperCase() : 'J';
                  final matchColor = AppColors.matchColor(job.matchPercentage);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          context.push(AppRoutes.jobDetails, extra: job),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.softBlue(context),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        job.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        job.location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => context
                                      .read<SavedJobsCubit>()
                                      .toggleSave(job),
                                  icon: const Icon(
                                    Icons.bookmark_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                if (job.workType.isNotEmpty)
                                  SkillChipBadge(label: job.workType),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: matchColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    strings.tr(
                                      'توافق ${job.matchPercentage}%',
                                      '${job.matchPercentage}% Match',
                                    ),
                                    style: TextStyle(
                                      color: matchColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Card(
                  color: AppColors.softBlue(context),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bookmark_added_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            strings.tr(
                              'احتفظ بالوظائف المهمة في مكان واحد للرجوع إليها في أي وقت.',
                              'Keep important jobs in one place to revisit anytime.',
                            ),
                            style: TextStyle(
                              color: AppColors.softBlueFg(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
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
