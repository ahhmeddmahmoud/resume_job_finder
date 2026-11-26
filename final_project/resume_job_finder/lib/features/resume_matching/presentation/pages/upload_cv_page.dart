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

/// 09 — Upload CV (PDF) screen.
class UploadCvPage extends StatefulWidget {
  const UploadCvPage({super.key});

  @override
  State<UploadCvPage> createState() => _UploadCvPageState();
}

class _UploadCvPageState extends State<UploadCvPage> {
  String? _selectedFileName;

  Future<void> _pickPdf() async {
    final cubit = context.read<ResumeMatchingCubit>();
    final picked = await cubit.pickPdfFile();
    if (!mounted || !picked) return;
    final currentName = cubit.selectedFileName;
    setState(() {
      _selectedFileName = currentName ?? 'resume.pdf';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppHeaderBar(
        title: strings.tr('رفع السيرة الذاتية', 'Upload Resume'),
      ),
      body: SafeArea(
        child: BlocBuilder<ResumeMatchingCubit, ResumeMatchingState>(
          builder: (context, state) {
            final hasChosenFile = _selectedFileName != null;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          strings.tr(
                            'ملفات PDF حتى 10 ميجابايت',
                            'PDF files up to 10 MB',
                          ),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state.status == ResumeMatchingStatus.error &&
                            state.errorMessage != null) ...[
                          AppStatusBanner(
                            message: state.errorMessage!,
                            type: BannerType.error,
                          ),
                          const SizedBox(height: 16),
                        ],
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: state.isLoading ? null : _pickPdf,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 38,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.45),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: hasChosenFile
                                        ? AppColors.softGreen(context)
                                        : AppColors.softBlue(context),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    hasChosenFile
                                        ? Icons.picture_as_pdf_rounded
                                        : Icons.cloud_upload_outlined,
                                    size: 34,
                                    color: hasChosenFile
                                        ? AppColors.success
                                        : AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  hasChosenFile
                                      ? _selectedFileName!
                                      : strings.tr(
                                          'اختر ملف سيرتك الذاتية',
                                          'Choose Your Resume File',
                                        ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  hasChosenFile
                                      ? strings.tr(
                                          'تم اختيار الملف بنجاح — اضغط للاستبدال أو ابدأ التحليل',
                                          'File selected — tap to replace or continue below',
                                        )
                                      : strings.tr(
                                          'اضغط هنا لاختيار ملف PDF من جهازك',
                                          'Tap here to select a PDF file from your device',
                                        ),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          strings.tr(
                            'ماذا سيحدث بعد الرفع؟',
                            'What Happens After Upload?',
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _StepRow(
                          number: '1',
                          text: strings.tr(
                            'استخراج المهارات والخبرات من ملف الـ PDF محليًا',
                            'Extract skills and experience locally from the PDF',
                          ),
                        ),
                        const SizedBox(height: 10),
                        _StepRow(
                          number: '2',
                          text: strings.tr(
                            'إنشاء تقرير ذكي للسيرة ونقاط القوة والفجوات',
                            'Generate a smart resume report with strengths & gaps',
                          ),
                        ),
                        const SizedBox(height: 10),
                        _StepRow(
                          number: '3',
                          text: strings.tr(
                            'البحث عن الوظائف المناسبة وحساب نسبة التوافق',
                            'Match relevant jobs and calculate match percentages',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: GradientPrimaryButton(
                    label: hasChosenFile
                        ? strings.tr(
                            'متابعة التحليل: $_selectedFileName',
                            'Continue: $_selectedFileName',
                          )
                        : strings.tr(
                            'اختر ملف PDF أولاً',
                            'Select a PDF File First',
                          ),
                    trailingIcon:
                        hasChosenFile ? Icons.arrow_forward_rounded : null,
                    isLoading: state.isLoading,
                    onPressed: hasChosenFile
                        ? () => context.push(AppRoutes.cvAnalysisLoading)
                        : null,
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

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: AppColors.softBlue(context),
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
