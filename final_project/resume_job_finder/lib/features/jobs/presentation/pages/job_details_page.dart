import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../../../core/widgets/circular_match_indicator.dart';
import '../../../../core/widgets/gradient_primary_button.dart';
import '../../../../core/widgets/skill_chip_badge.dart';
import '../../../applications/cubit/applications_cubit.dart';
import '../../../resume_matching/cubit/resume_matching_cubit.dart';
import '../../../resume_matching/models/resume_analysis_model.dart';
import '../../cubit/saved_jobs_cubit.dart';

/// 14 — Job Details & Match screen.
class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({
    super.key,
    required this.job,
  });

  final JobMatchModel job;

  String _matchTitle(AppStrings strings, int pct) {
    if (pct >= 80) {
      return strings.tr('توافق ممتاز مع الوظيفة', 'Excellent Job Match');
    }
    if (pct >= 50) {
      return strings.tr('توافق جيد مع الوظيفة', 'Good Job Match');
    }
    return strings.tr(
      'توافق مبدئي — يحتاج تطوير مهارات',
      'Initial Match — Needs Upskilling',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final cvSkills = job.matchedSkills.isNotEmpty
        ? job.matchedSkills
        : (context.watch<ResumeMatchingCubit>().state.analysis?.matchedSkills ??
            const []);
    final locationLabel = job.isRemote &&
            (job.location.isEmpty || job.location.toLowerCase() == 'remote')
        ? strings.tr('عن بُعد', 'Remote')
        : job.location;
    final initial = job.title.isNotEmpty ? job.title[0].toUpperCase() : 'J';

    return Scaffold(
      appBar: AppHeaderBar(
        title: strings.tr('تفاصيل الوظيفة', 'Job Details'),
        trailingAction: BlocBuilder<SavedJobsCubit, SavedJobsState>(
          builder: (context, savedState) {
            final isSaved = savedState.isSaved(job);
            return IconButton(
              onPressed: () => context.read<SavedJobsCubit>().toggleSave(job),
              icon: Icon(
                isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: isSaved ? AppColors.primary : null,
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.softBlue(context),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      job.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [job.companyType, locationLabel, job.workType]
                          .where((e) => e.isNotEmpty)
                          .join(' • '),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                    if (job.description?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 18),
                      Text(
                        strings.tr('وصف الوظيفة', 'Job Description'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(job.description!.trim()),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircularMatchIndicator(
                              percentage: job.matchPercentage,
                              size: 78,
                              subtitle: strings.tr('توافق', 'Match'),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _matchTitle(strings, job.matchPercentage),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.matchColor(
                                        job.matchPercentage,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    job.matchReason.isNotEmpty
                                        ? job.matchReason
                                        : strings.tr(
                                            'مطابقة بناءً على مهارات سيرتك الذاتية.',
                                            'Matched based on your resume skills.',
                                          ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      height: 1.45,
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
                        'المهارات الأساسية المطلوبة',
                        'Required Core Skills',
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: cvSkills.isEmpty
                            ? Text(
                                strings.tr(
                                  'ارفع سيرتك الذاتية لعرض المهارات المتطابقة.',
                                  'Upload your resume to see matched skills.',
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: cvSkills
                                    .take(6)
                                    .map(
                                      (s) => SkillChipBadge(
                                        label: s,
                                        isMatched: true,
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ),
                    if (job.missingSkills.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(
                        strings.tr(
                          'المهارات المفضلة للتطوير',
                          'Preferred / Missing Skills',
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
                            children: job.missingSkills
                                .map(
                                  (s) => SkillChipBadge(
                                    label: s,
                                    isMissing: true,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: BlocBuilder<ApplicationsCubit, ApplicationsState>(
                builder: (context, appState) {
                  return GradientPrimaryButton(
                    label: strings.tr('التقديم على الوظيفة', 'Apply Now'),
                    trailingIcon: Icons.arrow_forward_rounded,
                    isLoading:
                        appState.status == ApplicationsStateStatus.submitting,
                    onPressed: () async {
                      final applyUrl = job.applyUrl?.trim() ?? '';
                      if (applyUrl.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(strings.tr(
                              'لا يوجد رابط تقديم مباشر لهذه الوظيفة. يمكنك التقديم يدويًا من موقع الشركة.',
                              'No direct application link is available. You can apply manually on the company website.',
                            )),
                          ),
                        );
                      } else {
                        final uri = Uri.tryParse(applyUrl);
                        var launched = false;
                        if (uri != null) {
                          try {
                            launched = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (_) {
                            launched = false;
                          }
                        }
                        if (!launched) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(strings.tr(
                                'تعذر فتح رابط التقديم.',
                                'Could not open the application link.',
                              )),
                            ),
                          );
                        }
                      }
                      if (!context.mounted) return;
                      final didApply = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(strings.tr(
                            'هل قدمت على هذه الوظيفة؟',
                            'Did you apply for this job?',
                          )),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: Text(strings.tr('لا', 'No')),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child:
                                  Text(strings.tr('نعم، قدمت', 'Yes, Applied')),
                            ),
                          ],
                        ),
                      );
                      if (!context.mounted || didApply != true) return;
                      final created = await context
                          .read<ApplicationsCubit>()
                          .applyToJob(job);
                      if (!context.mounted || created == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(strings.tr(
                              'تعذر تسجيل طلبك. حاول مرة أخرى.',
                              'Could not record your application. Please try again.',
                            ))),
                          );
                        }
                        return;
                      }
                      context.push(AppRoutes.applyConfirmation, extra: job);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
