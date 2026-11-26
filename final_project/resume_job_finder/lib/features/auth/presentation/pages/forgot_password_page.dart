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

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final strings = AppStrings.of(context);
    context.read<AuthCubit>().sendPasswordResetLink(
          email: _emailController.text,
          genericErrorMessage: strings.tr(
            'يرجى إدخال بريد إلكتروني صحيح.',
            'Please enter a valid email address.',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isSent = state.status == AuthStatus.resetLinkSent;

        return Scaffold(
          appBar: AppBar(title: Text(strings.forgotPasswordTitle)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.forgotPasswordSubtitle,
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
                    if (isSent) ...[
                      AppStatusBanner(
                        message: strings.resetLinkSentSuccess,
                        type: BannerType.success,
                      ),
                      const SizedBox(height: 16),
                    ],
                    CustomTextField(
                      controller: _emailController,
                      label: strings.emailLabel,
                      hint: strings.emailHint,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      enabled: !state.isLoading,
                      validator: (v) => AppValidators.email(context, v),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: strings.sendResetLink,
                      isLoading: state.isLoading,
                      onPressed: _submit,
                    ),
                    if (isSent) ...[
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () {
                          context.read<AuthCubit>().clearStatus();
                          context.push(AppRoutes.resetPassword);
                        },
                        icon: const Icon(Icons.lock_reset_rounded),
                        label: Text(strings.proceedToReset),
                      ),
                    ],
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
