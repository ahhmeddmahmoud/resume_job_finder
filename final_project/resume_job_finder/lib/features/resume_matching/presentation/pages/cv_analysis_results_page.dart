import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../../../core/widgets/circular_match_indicator.dart';
import '../../../../core/widgets/gradient_primary_button.dart';
import '../../../../core/widgets/skill_chip_badge.dart';
import '../../cubit/resume_matching_cubit.dart';
import '../../cubit/resume_matching_state.dart';

/// 12 — CV Analysis Results screen.
class CvAnalysisResultsPage extends StatelessWidget {
  const CvAnalysisResultsPage({super.key});

  String _ratingHeadline(AppStrings strings, int pct) {
    if (pct >= 85) return strings.tr('توافق ممتاز', 'Excellent Match');
    if (pct >= 65) return strings.tr('بداية مهنية قوية', 'Strong Career Fit');
    return strings.tr('فرصة جيدة للتطوير', 'Good Room to Grow');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppHeaderBar(
        title: strings.tr('تحليل السيرة الذاتية', 'Resume Analysis'),
      ),
      body: SafeArea(
        child: BlocBuilder<ResumeMatchingCubit, ResumeMatchingState>(
          builder: (context, state) {
            final analysis = state.analysis;
            if (analysis == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.tr(
                          'لا توجد نتائج تحليل متاحة حاليًا.',
                          'No analysis results available yet.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      GradientPrimaryButton(
                        label: strings.tr('رفع سيرة ذاتية', 'Upload Resume'),
                        onPressed: () => context.push(AppRoutes.uploadCv),
                      ),
                    ],
                  ),
                ),
              );
            }

            final pct = analysis.matchPercentage;
            final skillsScore = ((analysis.matchedSkills.length / 6) * 100)
                .round()
                .clamp(45, 98);
            final expScore = (55 + analysis.experienceYears * 10).clamp(55, 96);
            final formatScore = analysis.skills.length >= 4 ? 88 : 74;
            final jobsScore = analysis.recommendedJobs.isNotEmpty
                ? analysis.recommendedJobs.first.matchPercentage
                : pct;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          CircularMatchIndicator(
                            percentage: pct,
                            size: 86,
                            subtitle: strings.tr('توافق', 'Match'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.softBlue(context),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    analysis.isLocalFallback
                                        ? 'Local Analyzer'
                                        : 'Gemini AI',
                                    style: TextStyle(
                                      color: AppColors.softBlueFg(context),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _ratingHeadline(strings, pct),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  analysis.fileName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    strings.tr(
                      'المهارات المستخرجة والمتطابقة',
                      'Extracted & Matched Skills',
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: analysis.matchedSkills
                            .map((s) =>
                                SkillChipBadge(label: s, isMatched: true))
                            .toList(),
                      ),
                    ),
                  ),
                  if (analysis.missingSkills.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      strings.tr(
                        'المهارات الناقصة والمقترحة',
                        'Missing & Suggested Skills',
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: analysis.missingSkills
                              .map(
                                (s) =>
                                    SkillChipBadge(label: s, isMissing: true),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    strings.tr('تفاصيل تقييم السيرة', 'Resume Score Breakdown'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _EvalBarRow(
                            label: strings.tr('المهارات', 'Skills'),
                            percent: skillsScore,
                          ),
                          const SizedBox(height: 12),
                          _EvalBarRow(
                            label: strings.tr('الخبرات', 'Experience'),
                            percent: expScore,
                          ),
                          const SizedBox(height: 12),
                          _EvalBarRow(
                            label: strings.tr('التنسيق', 'Formatting'),
                            percent: formatScore,
                          ),
                          const SizedBox(height: 12),
                          _EvalBarRow(
                            label: strings.tr('توافق الوظائف', 'Job Match'),
                            percent: jobsScore,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientPrimaryButton(
                    label: strings.tr(
                      'عرض الوظائف المناسبة',
                      'View Matching Jobs',
                    ),
                    trailingIcon: Icons.arrow_forward_rounded,
                    onPressed: () => context.go(AppRoutes.jobs),
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

class _EvalBarRow extends StatelessWidget {
  const _EvalBarRow({required this.label, required this.percent});

  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.matchColor(percent);

    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$percent%',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
