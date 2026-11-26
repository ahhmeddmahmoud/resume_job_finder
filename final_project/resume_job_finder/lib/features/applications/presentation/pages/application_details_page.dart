import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../models/job_application_model.dart';

/// 18 — Application Details screen with vertical timeline stepper.
class ApplicationDetailsPage extends StatelessWidget {
  const ApplicationDetailsPage({
    super.key,
    required this.application,
  });

  final JobApplicationModel application;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final dateStr = application.appliedAt.toLocal().toString().split('.').first;

    final currentStep = switch (application.status) {
      ApplicationStatus.applied || ApplicationStatus.submitted => 0,
      ApplicationStatus.underReview => 1,
      ApplicationStatus.interview => 2,
      ApplicationStatus.accepted || ApplicationStatus.rejected => 3,
    };

    final completedLabel = strings.tr('مكتمل', 'Completed');
    final pendingLabel = strings.tr('قيد الانتظار', 'Pending');

    final stages = [
      (strings.tr('تم إرسال الطلب', 'Application Submitted'), dateStr),
      (
        strings.tr('قيد المراجعة', 'Under Review'),
        currentStep >= 1 ? completedLabel : pendingLabel,
      ),
      (
        strings.tr('المقابلة', 'Interview'),
        currentStep >= 2 ? completedLabel : pendingLabel,
      ),
      (
        strings.tr('القرار النهائي', 'Final Decision'),
        currentStep >= 3
            ? application.status.localizedLabel(isArabic: strings.isArabic)
            : pendingLabel,
      ),
    ];

    return Scaffold(
      appBar: AppHeaderBar(
        title: strings.tr('تفاصيل طلب التوظيف', 'Application Details'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                          Icons.work_outline_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              application.jobTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [application.location, application.workType]
                                  .where((e) => e.isNotEmpty)
                                  .join(' • '),
                              style: theme.textTheme.bodySmall,
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
                strings.tr('مراحل التقديم', 'Application Stages'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: stages.length,
                  itemBuilder: (context, index) {
                    final isDone = index <= currentStep;
                    final isLast = index == stages.length - 1;
                    final stage = stages[index];

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Icon(
                              isDone
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isDone
                                  ? AppColors.success
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.35),
                              size: 22,
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 38,
                                color: isDone
                                    ? AppColors.success.withValues(alpha: 0.4)
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.15),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stage.$1,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  stage.$2,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.65),
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
              OutlinedButton(
                onPressed: () => context.pop(),
                child: Text(
                  strings.tr('العودة للطلبات', 'Back to Applications'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
