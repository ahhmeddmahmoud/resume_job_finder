import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_status_banner.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final strings = AppStrings.of(context);
    context.read<AuthCubit>().resetPassword(
          newPassword: _newPasswordController.text,
          genericErrorMessage: strings.tr(
            'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل.',
            'New password must be at least 6 characters.',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isSuccess = state.status == AuthStatus.passwordResetSuccess;

        return Scaffold(
          appBar: AppBar(title: Text(strings.resetPasswordTitle)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.resetPasswordSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (state.status == AuthStatus.error &&
                        state.errorMessage != null) ...[
                      AppStatusBanner(
                        message: state.errorMessage!,
                        type: BannerType.error,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (isSuccess) ...[
                      AppStatusBanner(
                        message: strings.resetPasswordSuccess,
                        type: BannerType.success,
                      ),
                      const SizedBox(height: 16),
                    ],
                    CustomTextField(
                      controller: _newPasswordController,
                      label: strings.newPasswordLabel,
                      hint: strings.passwordHint,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      enabled: !state.isLoading && !isSuccess,
                      validator: (v) => AppValidators.password(context, v),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: strings.confirmPasswordLabel,
                      hint: strings.passwordHint,
                      prefixIcon: Icons.lock_reset_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      enabled: !state.isLoading && !isSuccess,
                      validator: (v) => AppValidators.confirmPassword(
                        context,
                        v,
                        _newPasswordController.text,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!isSuccess)
                      PrimaryButton(
                        label: strings.resetPasswordButton,
                        isLoading: state.isLoading,
                        onPressed: _submit,
                      )
                    else
                      PrimaryButton(
                        label: strings.backToLogin,
                        onPressed: () {
                          context.read<AuthCubit>().clearStatus();
                          context.go(AppRoutes.login);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
