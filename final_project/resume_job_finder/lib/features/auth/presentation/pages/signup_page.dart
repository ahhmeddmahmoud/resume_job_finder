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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    setState(() => _showTermsError = !_acceptedTerms);
    if (!isFormValid || !_acceptedTerms) return;

    final strings = AppStrings.of(context);
    context.read<AuthCubit>().signUp(
          fullName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          genericErrorMessage: strings.tr(
            'تعذّر إنشاء الحساب، يرجى مراجعة البيانات المدخلة.',
            'Could not create account. Please review your details.',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.registered) {
          context.go(AppRoutes.careerPreferences);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(strings.signUpTitle)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.signUpSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.70),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (state.status == AuthStatus.error &&
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
                      hint: strings.fullNameHint,
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      enabled: !state.isLoading,
                      validator: (v) => AppValidators.fullName(context, v),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: strings.emailLabel,
                      hint: strings.emailHint,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !state.isLoading,
                      validator: (v) => AppValidators.email(context, v),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: strings.passwordLabel,
                      hint: strings.passwordHint,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      enabled: !state.isLoading,
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
                      enabled: !state.isLoading,
                      validator: (v) => AppValidators.confirmPassword(
                        context,
                        v,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 14),
                    CheckboxListTile(
                      value: _acceptedTerms,
                      enabled: !state.isLoading,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                          if (_acceptedTerms) _showTermsError = false;
                        });
                      },
                      title: Text(
                        strings.acceptTerms,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    if (_showTermsError) ...[
                      AppStatusBanner(
                        message: strings.termsRequiredError,
                        type: BannerType.error,
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: strings.createAccount,
                      isLoading: state.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(strings.alreadyHaveAccount),
                        TextButton(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  context.read<AuthCubit>().clearStatus();
                                  context.pop();
                                },
                          child: Text(
                            strings.loginButton,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
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
