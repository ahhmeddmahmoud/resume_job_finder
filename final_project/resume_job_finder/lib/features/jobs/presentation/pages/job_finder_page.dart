import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_primary_button.dart';
import '../../../../core/widgets/skill_chip_badge.dart';
import '../../../resume_matching/cubit/resume_matching_cubit.dart';
import '../../../resume_matching/cubit/resume_matching_state.dart';
import '../../../resume_matching/models/resume_analysis_model.dart';
import '../../cubit/saved_jobs_cubit.dart';

/// 13 — Job Finder screen with search, filter chips, sort indicator, and bookmark toggle.
class JobFinderPage extends StatefulWidget {
  const JobFinderPage({super.key});

  @override
  State<JobFinderPage> createState() => _JobFinderPageState();
}

class _JobFinderPageState extends State<JobFinderPage> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<JobMatchModel> _applyFilters(List<JobMatchModel> jobs) {
    final query = _searchController.text.trim().toLowerCase();
    return jobs.where((job) {
      final matchesQuery = query.isEmpty ||
          job.title.toLowerCase().contains(query) ||
          job.companyType.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query);

      final matchesFilter = switch (_selectedFilter) {
        'all' => true,
        'remote' => job.workType.toLowerCase().contains('remote') ||
            job.workType.contains('عن بعد') ||
            job.location.toLowerCase().contains('remote'),
        _ => job.title.toLowerCase().contains(_selectedFilter.toLowerCase()) ||
            job.matchReason
                .toLowerCase()
                .contains(_selectedFilter.toLowerCase()),
      };

      return matchesQuery && matchesFilter;
    }).toList()
      ..sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    final filters = [
      (key: 'all', label: strings.tr('الكل', 'All')),
      (key: 'Flutter', label: 'Flutter'),
      (key: 'remote', label: strings.tr('عن بُعد', 'Remote')),
      (key: 'Frontend', label: 'Frontend'),
      (key: 'Backend', label: 'Backend'),
      (key: 'Mobile', label: 'Mobile'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.tr('الوظائف المناسبة', 'Matching Jobs')),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ResumeMatchingCubit, ResumeMatchingState>(
          builder: (context, cvState) {
            if (cvState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final allJobs = cvState.analysis?.recommendedJobs ?? const [];
            if (allJobs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        size: 64,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        strings.tr(
                          'لا توجد وظائف مطابقة بعد',
                          'No Matching Jobs Yet',
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.tr(
                          'ارفع سيرتك الذاتية (PDF) ليعرض التطبيق الوظائف المناسبة مرتبة حسب نسبة التوافق.',
                          'Upload your PDF resume to view jobs sorted by match percentage.',
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.68),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GradientPrimaryButton(
                        label: strings.tr(
                          'رفع السيرة الذاتية',
                          'Upload Resume',
                        ),
                        onPressed: () => context.push(AppRoutes.uploadCv),
                      ),
                    ],
                  ),
                ),
              );
            }

            final filteredJobs = _applyFilters(allJobs);
            final liveJobCount = allJobs.where((job) => job.isRealJob).length;

            return BlocBuilder<SavedJobsCubit, SavedJobsState>(
              builder: (context, savedState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: strings.tr(
                            'ابحث عن وظيفة أو شركة...',
                            'Search job title or company...',
                          ),
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsetsDirectional.only(
                        start: 20,
                        end: 20,
                      ),
                      child: Row(
                        children: filters.map((filter) {
                          final isSelected = _selectedFilter == filter.key;
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: ChoiceChip(
                              label: Text(filter.label),
                              selected: isSelected,
                              onSelected: (_) => setState(
                                () => _selectedFilter = filter.key,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                      child: Text(
                        strings.tr(
                          'مرتبة حسب أعلى توافق (${filteredJobs.length})',
                          'Sorted by highest match (${filteredJobs.length})',
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
                      child: Text(
                        liveJobCount > 0
                            ? strings.tr(
                                'المصدر: وظائف جلبها JSearch ($liveJobCount)',
                                'Source: jobs fetched from JSearch ($liveJobCount)',
                              )
                            : strings.tr(
                                'المصدر: وظائف محلية تجريبية؛ البحث المباشر غير متاح حاليًا.',
                                'Source: local sample jobs; live search is currently unavailable.',
                              ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: liveJobCount > 0
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredJobs.isEmpty
                          ? Center(
                              child: Text(
                                strings.tr(
                                  'لا توجد نتائج مطابقة لبحثك.',
                                  'No jobs match your search.',
                                ),
                                style: theme.textTheme.bodyMedium,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                4,
                                20,
                                112,
                              ),
                              itemCount: filteredJobs.length,
                              itemBuilder: (context, index) {
                                final job = filteredJobs[index];
                                final isSaved = savedState.isSaved(job);
                                return _JobCard(
                                  job: job,
                                  isSaved: isSaved,
                                  onBookmarkTap: () => context
                                      .read<SavedJobsCubit>()
                                      .toggleSave(job),
                                  onTap: () => context.push(
                                    AppRoutes.jobDetails,
                                    extra: job,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.isSaved,
    required this.onBookmarkTap,
    required this.onTap,
  });

  final JobMatchModel job;
  final bool isSaved;
  final VoidCallback onBookmarkTap;
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
    final matchColor = AppColors.matchColor(job.matchPercentage);

    final loc = _localizeWorkType(strings, job.location);
    final wt = _localizeWorkType(strings, job.workType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                        if (job.companyType.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            job.companyType,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.72),
                            ),
                          ),
                        ],
                        if (loc.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            loc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.58),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onBookmarkTap,
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isSaved
                          ? AppColors.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
  }
}
