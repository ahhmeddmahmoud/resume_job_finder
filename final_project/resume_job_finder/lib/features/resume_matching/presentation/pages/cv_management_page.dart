import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_tile_card.dart';
import '../../cubit/resume_matching_cubit.dart';
import '../../cubit/resume_matching_state.dart';

/// 10 — CV Management screen.
class CvManagementPage extends StatelessWidget {
  const CvManagementPage({super.key});

  Future<void> _confirmDelete(BuildContext context) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.tr('حذف السيرة الذاتية', 'Delete Resume')),
        content: Text(
          strings.tr(
            'هل أنت متأكد من حذف بيانات السيرة الذاتية ونتيجة التحليل المحفوظة؟',
            'Are you sure you want to delete your saved resume and analysis data?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(strings.tr('إلغاء', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              strings.tr('حذف', 'Delete'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ResumeMatchingCubit>().deleteCv();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              strings.tr(
                'تم حذف بيانات السيرة الذاتية بنجاح.',
                'Resume data deleted successfully.',
              ),
            ),
          ),
        );
        context.go(AppRoutes.home);
      }
    }
  }

  Future<void> _replaceCv(BuildContext context) async {
    final cubit = context.read<ResumeMatchingCubit>();
    final picked = await cubit.pickPdfFile();
    if (!context.mounted || !picked) return;
    context.push(AppRoutes.cvAnalysisLoading);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppHeaderBar(
        title: strings.tr('إدارة السيرة الذاتية', 'Resume Management'),
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
                      const Icon(
                        Icons.description_outlined,
                        size: 56,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        strings.tr(
                          'لا توجد سيرة ذاتية محفوظة حاليًا',
                          'No Saved Resume Currently',
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: strings.tr(
                          'رفع سيرة ذاتية (PDF)',
                          'Upload Resume (PDF)',
                        ),
                        onPressed: () => context.push(AppRoutes.uploadCv),
                      ),
                    ],
                  ),
                ),
              );
            }

            final dateStr = analysis.analyzedAt != null
                ? analysis.analyzedAt!.toLocal().toString().split(' ').first
                : strings.tr('اليوم', 'Today');

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.softBlue(context),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  analysis.fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  strings.tr(
                                    'PDF • تاريخ التحليل: $dateStr',
                                    'PDF • Analyzed: $dateStr',
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.softGreen(context),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    strings.tr(
                                      'تحليل مكتمل',
                                      'Analysis Complete',
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.success,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
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
                  const SizedBox(height: 20),
                  Text(
                    strings.tr('إدارة الملف', 'File Actions'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SectionTileCard(
                    icon: Icons.analytics_outlined,
                    title: strings.tr(
                      'عرض نتيجة التحليل',
                      'View Analysis Results',
                    ),
                    subtitle: strings.tr(
                      'توافق ${analysis.matchPercentage}% • ${analysis.matchedSkills.length} مهارة',
                      '${analysis.matchPercentage}% Match • ${analysis.matchedSkills.length} Skills',
                    ),
                    onTap: () => context.push(AppRoutes.cvAnalysisResults),
                  ),
                  SectionTileCard(
                    icon: Icons.refresh_rounded,
                    title:
                        strings.tr('إعادة تحليل السيرة', 'Re-analyze Resume'),
                    subtitle: strings.tr(
                      'تحديث المطابقة حسب التفضيلات الحالية',
                      'Refresh job matching with current preferences',
                    ),
                    onTap: () => context.push(AppRoutes.cvAnalysisLoading),
                  ),
                  SectionTileCard(
                    icon: Icons.upload_file_rounded,
                    title: strings.tr(
                      'استبدال السيرة الذاتية',
                      'Replace Resume',
                    ),
                    subtitle: strings.tr(
                      'اختيار ملف PDF جديد',
                      'Pick a new PDF file',
                    ),
                    onTap: () => _replaceCv(context),
                  ),
                  SectionTileCard(
                    icon: Icons.summarize_outlined,
                    title: strings.tr(
                      'ملخص التقرير المحفوظ',
                      'Saved Report Summary',
                    ),
                    subtitle: analysis.bestJobTitle,
                    onTap: () => context.push(AppRoutes.cvAnalysisResults),
                  ),
                  SectionTileCard(
                    icon: Icons.delete_outline_rounded,
                    iconColor: AppColors.error,
                    title: strings.tr('حذف السيرة الذاتية', 'Delete Resume'),
                    subtitle: strings.tr(
                      'إزالة بيانات التحليل من الحساب',
                      'Remove saved analysis data from your account',
                    ),
                    onTap: () => _confirmDelete(context),
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
