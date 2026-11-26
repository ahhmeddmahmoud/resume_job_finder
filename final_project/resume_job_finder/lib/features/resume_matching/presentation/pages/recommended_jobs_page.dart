import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_status_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/settings_quick_actions.dart';
import '../../cubit/resume_matching_cubit.dart';
import '../../cubit/resume_matching_state.dart';
import '../../models/resume_analysis_model.dart';

class RecommendedJobsPage extends StatelessWidget {
  const RecommendedJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الوظائف المرشحة والنتائج'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SettingsQuickActions(),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ResumeMatchingCubit, ResumeMatchingState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        state.loadingMessage ?? 'جارٍ تحليل السيرة الذاتية...',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.status == ResumeMatchingStatus.error &&
                state.errorMessage != null &&
                state.analysis == null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppStatusBanner(
                      message: state.errorMessage!,
                      type: BannerType.error,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'العودة لتحليل السيرة الذاتية',
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                  ],
                ),
              );
            }

            final analysis = state.analysis;
            if (analysis == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.work_off_outlined,
                        size: 64,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد نتائج مطابقة بعد',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'قم برفع سيرتك الذاتية (PDF) في تبويب التحليل لعرض نسبة التوافق والوظائف المرشحة.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.68),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'رفع وتحليل السيرة الذاتية',
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryBannerCard(analysis: analysis),
                  const SizedBox(height: 16),
                  _SkillsWrapCard(
                    title:
                        'المهارات المتطابقة (${analysis.matchedSkills.length})',
                    items: analysis.matchedSkills,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  _SkillsWrapCard(
                    title:
                        'المهارات الناقصة (${analysis.missingSkills.length})',
                    items: analysis.missingSkills,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'الوظائف المرشحة (${analysis.recommendedJobs.length})',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...analysis.recommendedJobs.map(
                    (job) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RecommendedJobCard(job: job),
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

class _SummaryBannerCard extends StatelessWidget {
  const _SummaryBannerCard({required this.analysis});

  final ResumeAnalysisModel analysis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = analysis.matchPercentage;
    final scoreColor = score >= 75
        ? AppColors.success
        : score >= 50
            ? AppColors.warning
            : AppColors.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withValues(alpha: 0.14),
              ),
              child: Center(
                child: Text(
                  '$score%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analysis.bestJobTitle.isNotEmpty
                        ? analysis.bestJobTitle
                        : 'نتيجة المطابقة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    analysis.isLocalFallback
                        ? 'المصدر: Local Analyzer'
                        : 'المصدر: Gemini AI',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillsWrapCard extends StatelessWidget {
  const _SkillsWrapCard({
    required this.title,
    required this.items,
    required this.color,
  });

  final String title;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (s) => Chip(
                      label: Text(s),
                      backgroundColor: color.withValues(alpha: 0.1),
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedJobCard extends StatelessWidget {
  const _RecommendedJobCard({required this.job});

  final JobMatchModel job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchColor = job.matchPercentage >= 75
        ? AppColors.success
        : job.matchPercentage >= 50
            ? AppColors.warning
            : AppColors.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: matchColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${job.matchPercentage}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: matchColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              [job.companyType, job.location, job.workType]
                  .where((e) => e.isNotEmpty)
                  .join(' • '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: job.matchPercentage / 100,
                minHeight: 7,
                color: matchColor,
                backgroundColor: matchColor.withValues(alpha: 0.14),
              ),
            ),
            if (job.matchReason.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                job.matchReason,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ],
            if (job.missingSkills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'مهارات ناقصة: ${job.missingSkills.join('، ')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
