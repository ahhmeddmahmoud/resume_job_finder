import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../../../core/widgets/app_status_banner.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_primary_button.dart';
import '../../cubit/profile_cubit.dart';
import '../../cubit/profile_state.dart';

/// 20 — Edit Profile screen updating `users/{uid}` in Firestore.
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..loadProfile(),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();
  final _cityController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _sync(ProfileState state) {
    if (_initialized) return;
    if (state.status == ProfileStatus.loaded) {
      _nameController.text = state.fullName;
      _emailController.text = state.email;
      _roleController.text = state.targetRole;
      _cityController.text = state.city;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppHeaderBar(
        title: strings.tr('تعديل الملف الشخصي', 'Edit Profile'),
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            _sync(state);
            if (state.status == ProfileStatus.saved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    strings.tr(
                      'تم حفظ التعديلات بنجاح.',
                      'Profile changes saved.',
                    ),
                  ),
                ),
              );
              context.pop();
            }
          },
          builder: (context, state) {
            if (state.isLoading && !_initialized) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.softBlue(context),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (state.status == ProfileStatus.error &&
                        state.errorMessage != null) ...[
                      AppStatusBanner(
                        message: state.errorMessage!,
                        type: BannerType.error,
                      ),
                      const SizedBox(height: 16),
                    ],
                    CustomTextField(
                      controller: _nameController,
                      label: strings.fullNameLabel,
                      prefixIcon: Icons.person_outline_rounded,
                      enabled: !state.isSaving,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? strings.tr(
                              'يرجى إدخال الاسم الكامل',
                              'Please enter your full name',
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _emailController,
                      label: strings.emailLabel,
                      prefixIcon: Icons.email_outlined,
                      readOnly: true,
                      enabled: false,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _roleController,
                      label: strings.tr('المسمى الوظيفي', 'Job Title'),
                      hint: 'Flutter Developer',
                      prefixIcon: Icons.work_outline_rounded,
                      enabled: !state.isSaving,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _cityController,
                      label: strings.tr('المدينة', 'City'),
                      hint: strings.tr('القاهرة، مصر', 'Cairo, Egypt'),
                      prefixIcon: Icons.location_on_outlined,
                      enabled: !state.isSaving,
                    ),
                    const SizedBox(height: 28),
                    GradientPrimaryButton(
                      label: strings.tr('حفظ التعديلات', 'Save Changes'),
                      isLoading: state.isSaving,
                      onPressed: () {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        context.read<ProfileCubit>().updateProfileInfo(
                              fullName: _nameController.text,
                              targetRole: _roleController.text,
                              city: _cityController.text,
                            );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
