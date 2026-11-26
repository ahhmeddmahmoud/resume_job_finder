import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skill_chip_badge.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../profile_photo/cubit/profile_photo_cubit.dart';
import '../../../profile_photo/presentation/widgets/user_avatar.dart';
import '../../../resume_matching/cubit/resume_matching_cubit.dart';
import '../../../resume_matching/cubit/resume_matching_state.dart';
import '../../../resume_matching/models/resume_analysis_model.dart';

/// 08 — Home Dashboard.
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  String _loadedUid = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.watch<AuthCubit>().state.user?.uid ?? '';
    if (uid.isNotEmpty && uid != _loadedUid) {
      _loadedUid = uid;
      context.read<ProfilePhotoCubit>().loadPhoto(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final userName = authState.user?.name.isNotEmpty == true
                ? authState.user!.name
                : strings.tr('مستخدم DEPI', 'DEPI User');

            return BlocBuilder<ResumeMatchingCubit, ResumeMatchingState>(
              builder: (context, cvState) {
                final analysis = cvState.analysis;
                final matchPct = analysis?.matchPercentage ?? 0;
                final jobsCount = analysis?.recommendedJobs.length ?? 0;
                final skillsCount = analysis?.matchedSkills.length ?? 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 112),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.tr('أهلاً بك،', 'Welcome back,'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                                Text(
                                  userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BlocBuilder<ProfilePhotoCubit, ProfilePhotoState>(
                            builder: (context, photoState) {
                              return UserAvatar(
                                photoPath: photoState.photoPath,
                                displayName: userName,
                                size: 44,
                                cacheVersion: photoState.version,
                                onTap: () => context.go(AppRoutes.profile),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _HeroUploadCard(
                        onTap: () => context.push(AppRoutes.uploadCv),
                      ),
                      const SizedBox(height: 16),
                      _CurrentCvStatusCard(
                        analysis: analysis,
                        onManageTap: () => context.push(AppRoutes.cvManagement),
                        onUploadTap: () => context.push(AppRoutes.uploadCv),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              value: analysis != null ? '$matchPct%' : '--',
                              label: strings.tr('آخر توافق', 'Last Match'),
                              color: AppColors.matchColor(matchPct),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              value: '$jobsCount',
                              label: strings.tr('وظائف مناسبة', 'Matched Jobs'),
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              value: '$skillsCount',
                              label: strings.tr('مهارة مستخرجة', 'Skills'),
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              strings.tr(
                                'وظائف مختارة لك',
                                'Recommended Jobs for You',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(AppRoutes.jobs),
                            child: Text(
                              strings.tr('عرض الكل', 'View All'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (analysis == null || analysis.recommendedJobs.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.work_outline_rounded,
                                  size: 36,
                                  color:
                                      AppColors.primary.withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  strings.tr(
                                    'ارفع سيرتك الذاتية (PDF) لعرض الوظائف المرشحة ونسبة التوافق.',
                                    'Upload your PDF resume to see matched jobs and match scores.',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...analysis.recommendedJobs.take(3).map(
                              (job) => _HomeJobPreviewCard(
                                job: job,
                                onTap: () => context.push(
                                  AppRoutes.jobDetails,
                                  extra: job,
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HeroUploadCard extends StatelessWidget {
  const _HeroUploadCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.isDark(context)
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.tr(
                    'تحليل ذكي لسيرتك الذاتية',
                    'Smart Resume Analysis',
                  ),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  strings.tr(
                    'دع فرصتك المناسبة تجدك',
                    'Let the Right Opportunity Find You',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  strings.tr(
                    'ارفع ملف PDF لنستخرج مهاراتك ونحسب توافقك مع الوظائف.',
                    'Upload a PDF resume to extract your skills and compute job matches.',
                  ),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.upload_file_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          strings.tr(
                            'رفع وتحليل السيرة الذاتية',
                            'Upload & Analyze CV',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentCvStatusCard extends StatelessWidget {
  const _CurrentCvStatusCard({
    required this.analysis,
    required this.onManageTap,
    required this.onUploadTap,
  });

  final ResumeAnalysisModel? analysis;
  final VoidCallback onManageTap;
  final VoidCallback onUploadTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final hasCv = analysis != null;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: hasCv ? onManageTap : onUploadTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasCv
                      ? AppColors.softGreen(context)
                      : AppColors.softBlue(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasCv ? Icons.description_rounded : Icons.note_add_outlined,
                  color: hasCv ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasCv
                          ? strings.tr(
                              'تم تحليل سيرتك بنجاح',
                              'Resume Analyzed Successfully',
                            )
                          : strings.tr(
                              'لم يتم رفع سيرة ذاتية بعد',
                              'No Resume Uploaded Yet',
                            ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasCv
                          ? analysis!.fileName
                          : strings.tr(
                              'اضغط هنا لاختيار ملف PDF وبدء التحليل',
                              'Tap here to pick a PDF file and start analysis',
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeJobPreviewCard extends StatelessWidget {
  const _HomeJobPreviewCard({
    required this.job,
    required this.onTap,
  });

  final JobMatchModel job;
  final VoidCallback onTap;

  String _localizeWorkType(AppStrings strings, String raw) {
    return switch (raw.trim().toLowerCase()) {
      'remote' => strings.tr('عن بُعد', 'Remote'),
      'full-time' => strings.tr('دوام كامل', 'Full-time'),
      'part-time' => strings.tr('دوام جزئي', 'Part-time'),
      'hybrid' => strings.tr('هجين', 'Hybrid'),
      'freelance' => strings.tr('عمل حر', 'Freelance'),
      _ => raw,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final initial = job.title.isNotEmpty ? job.title[0].toUpperCase() : 'J';
    final color = AppColors.matchColor(job.matchPercentage);

    final loc = _localizeWorkType(strings, job.location);
    final wt = _localizeWorkType(strings, job.workType);
    final metaParts = <String>[
      if (loc.isNotEmpty) loc,
      if (wt.isNotEmpty && wt.toLowerCase() != loc.toLowerCase()) wt,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (metaParts.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            metaParts.join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (wt.isNotEmpty) SkillChipBadge(label: wt),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      strings.tr(
                        'توافق ${job.matchPercentage}%',
                        '${job.matchPercentage}% Match',
                      ),
                      style: TextStyle(
                        color: color,
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
  }
}
