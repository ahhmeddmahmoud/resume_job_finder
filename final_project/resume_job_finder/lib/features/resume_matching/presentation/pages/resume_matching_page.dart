import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_status_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/settings_quick_actions.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../cubit/resume_matching_cubit.dart';
import '../../cubit/resume_matching_state.dart';
import '../../models/resume_analysis_model.dart';

class ResumeMatchingPage extends StatelessWidget {
  const ResumeMatchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ResumeMatchingView();
  }
}

class _ResumeMatchingView extends StatelessWidget {
  const _ResumeMatchingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState.status == AuthStatus.loggedOut) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مطابقة السيرة الذاتية'),
          actions: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: SettingsQuickActions(),
            ),
            IconButton(
              tooltip: 'التفضيلات المهنية',
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => context.push(AppRoutes.careerPreferences),
            ),
            IconButton(
              tooltip: 'تسجيل الخروج',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => context.read<AuthCubit>().signOut(),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<ResumeMatchingCubit, ResumeMatchingState>(
            builder: (context, state) {
              final cubit = context.read<ResumeMatchingCubit>();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _UploadCard(
                      isLoading: state.isLoading,
                      fileName: state.analysis?.fileName,
                      onPickAndAnalyze: cubit.pickAndAnalyzeResume,
                    ),
                    const SizedBox(height: 16),
                    if (state.isLoading) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 14),
                              Text(
                                state.loadingMessage ??
                                    'جارٍ تحليل السيرة الذاتية...',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (state.status == ResumeMatchingStatus.error &&
                        state.errorMessage != null) ...[
                      AppStatusBanner(
                        message: state.errorMessage!,
                        type: BannerType.error,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (state.analysis != null && !state.isLoading) ...[
                      _MatchScoreHeroCard(analysis: state.analysis!),
                      const SizedBox(height: 16),
                      _ChipsSectionCard(
                        title: 'المهارات المتطابقة (Matched Skills)',
                        icon: Icons.check_circle_outline_rounded,
                        items: state.analysis!.matchedSkills,
                        chipColor: AppColors.success,
                      ),
                      const SizedBox(height: 16),
                      _ChipsSectionCard(
                        title: 'المهارات الناقصة والمقترحة (Missing Skills)',
                        icon: Icons.trending_up_rounded,
                        items: state.analysis!.missingSkills,
                        chipColor: AppColors.warning,
                      ),
                      const SizedBox(height: 16),
                      _BulletSectionCard(
                        title: 'نقاط القوة',
                        icon: Icons.verified_outlined,
                        items: state.analysis!.strengths,
                        accentColor: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'الوظائف المرشحة (${state.analysis!.recommendedJobs.length})',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...state.analysis!.recommendedJobs.map(
                        (job) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _JobMatchCard(job: job),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.isLoading,
    required this.fileName,
    required this.onPickAndAnalyze,
  });

  final bool isLoading;
  final String? fileName;
  final VoidCallback onPickAndAnalyze;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تحليل السيرة الذاتية (PDF)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fileName != null
                            ? 'آخر ملف: $fileName'
                            : 'اختر ملف CV بصيغة PDF لاستخراج النص ومطابقته مع الوظائف',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.68),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: fileName != null
                  ? 'تحليل سيرة ذاتية أخرى (PDF)'
                  : 'اختيار ملف PDF وبدء التحليل',
              isLoading: isLoading,
              onPressed: onPickAndAnalyze,
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchScoreHeroCard extends StatelessWidget {
  const _MatchScoreHeroCard({required this.analysis});

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
    final sourceLabel =
        analysis.isLocalFallback ? 'Local Analyzer' : 'Gemini AI';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        color: scoreColor,
                        backgroundColor: scoreColor.withValues(alpha: 0.16),
                      ),
                      Center(
                        child: Text(
                          '$score%',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: scoreColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (analysis.isLocalFallback
                                  ? AppColors.secondary
                                  : AppColors.primary)
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              analysis.isLocalFallback
                                  ? Icons.offline_bolt_rounded
                                  : Icons.auto_awesome_rounded,
                              size: 14,
                              color: analysis.isLocalFallback
                                  ? AppColors.secondary
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              sourceLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: analysis.isLocalFallback
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        analysis.bestJobTitle.isNotEmpty
                            ? analysis.bestJobTitle
                            : 'نسبة التوافق الإجمالية',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${analysis.experienceYears} سنوات خبرة • ${analysis.matchedSkills.length} مهارة متطابقة',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (analysis.summary.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                analysis.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.84),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChipsSectionCard extends StatelessWidget {
  const _ChipsSectionCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.chipColor,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final Color chipColor;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: chipColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      backgroundColor: chipColor.withValues(alpha: 0.1),
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

class _BulletSectionCard extends StatelessWidget {
  const _BulletSectionCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.accentColor,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobMatchCard extends StatelessWidget {
  const _JobMatchCard({required this.job});

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
                    '${job.matchPercentage}% تطابق',
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
                'مهارات مقترحة للتطوير: ${job.missingSkills.join('، ')}',
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
