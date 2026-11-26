import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../../../core/widgets/app_status_banner.dart';
import '../../../../core/widgets/gradient_primary_button.dart';
import '../../cubit/resume_matching_cubit.dart';
import '../../cubit/resume_matching_state.dart';

/// 11 — CV Analysis Loading screen running the real AI/Local pipeline.
class CvAnalysisLoadingPage extends StatefulWidget {
  const CvAnalysisLoadingPage({super.key});

  @override
  State<CvAnalysisLoadingPage> createState() => _CvAnalysisLoadingPageState();
}

class _CvAnalysisLoadingPageState extends State<CvAnalysisLoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ResumeMatchingCubit>().runAnalysisPipeline();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final steps = [
      strings.tr('تجهيز نص السيرة الذاتية', 'Preparing resume text'),
      strings.tr('تحليل المهارات والتخصص', 'Analyzing skills and job track'),
      strings.tr('البحث عن وظائف عبر JSearch', 'Searching jobs with JSearch'),
      strings.tr('حساب التوافق وحفظ النتائج', 'Matching and saving results'),
    ];

    return Scaffold(
      appBar: AppHeaderBar(
        title: strings.tr('جارٍ تحليل سيرتك', 'Analyzing Your Resume'),
      ),
      body: SafeArea(
        child: BlocConsumer<ResumeMatchingCubit, ResumeMatchingState>(
          listener: (context, state) {
            if (state.status == ResumeMatchingStatus.loaded &&
                state.analysis != null) {
              context.go(AppRoutes.cvAnalysisResults);
            }
          },
          builder: (context, state) {
            final pct = state.progressPercent.clamp(0, 100);
            final softBlue = AppColors.softBlue(context);
            final stageDescription =
                state.status != ResumeMatchingStatus.loading
                    ? strings.tr(
                        'قد تستغرق العملية لحظات بسيطة...',
                        'This may take a few moments...',
                      )
                    : switch (state.currentStepIndex) {
                        0 => strings.tr(
                            'نجهّز النص المستخرج من ملف PDF.',
                            'Preparing the text extracted from your PDF.',
                          ),
                        1 => strings.tr(
                            'نحلل المهارات والتخصص؛ Gemini أو المحلل المحلي عند تعذر الاتصال.',
                            'Analyzing skills and role; local analysis takes over if Gemini is unavailable.',
                          ),
                        2 => strings.tr(
                            'نطلب وظائف مناسبة من JSearch؛ سنعرض الاقتراحات المحلية إذا تعذر الاتصال.',
                            'Requesting matching jobs from JSearch; local suggestions appear if it is unavailable.',
                          ),
                        _ when pct >= 90 => strings.tr(
                            'نحفظ النتيجة؛ لن يمنع تعذر Firestore ظهور التحليل.',
                            'Saving results; a Firestore outage will not block the analysis.',
                          ),
                        _ => strings.tr(
                            'نجهّز نتيجة التحليل.',
                            'Finalizing the analysis.',
                          ),
                      };

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      child: Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          color: softBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 46,
                          color: AppColors.primary,
                        ),
                      ),
                      builder: (context, child) => Transform.scale(
                        scale: 0.97 + (_pulseController.value * 0.03),
                        child: child,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    strings.tr(
                      'بنكتشف مهاراتك ونقاط قوتك',
                      'Discovering Your Skills & Strengths',
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      stageDescription,
                      key: ValueKey(stageDescription),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$pct%',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 8,
                      color: AppColors.primary,
                      backgroundColor: softBlue,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ...List.generate(steps.length, (i) {
                    final isDone = i < state.currentStepIndex ||
                        state.status == ResumeMatchingStatus.loaded;
                    final isActive = i == state.currentStepIndex &&
                        state.status == ResumeMatchingStatus.loading;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : isActive
                                    ? Icons.auto_awesome_rounded
                                    : Icons.radio_button_unchecked_rounded,
                            color: isDone
                                ? AppColors.success
                                : isActive
                                    ? AppColors.primary
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.35),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              steps[i],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: isActive || isDone
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (state.status == ResumeMatchingStatus.error &&
                      state.errorMessage != null) ...[
                    const SizedBox(height: 20),
                    AppStatusBanner(
                      message: state.errorMessage!,
                      type: BannerType.error,
                    ),
                    const SizedBox(height: 14),
                    GradientPrimaryButton(
                      label: strings.tr('إعادة المحاولة', 'Try Again'),
                      onPressed: () => context
                          .read<ResumeMatchingCubit>()
                          .runAnalysisPipeline(),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
