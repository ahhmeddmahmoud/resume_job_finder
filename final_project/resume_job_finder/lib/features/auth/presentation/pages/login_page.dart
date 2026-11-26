import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_status_banner.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/settings_quick_actions.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
import '../widgets/social_auth_buttons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final strings = AppStrings.of(context);
    context.read<AuthCubit>().login(
          email: _emailController.text,
          password: _passwordController.text,
          invalidCredentialsMessage: strings.tr(
            'تأكد من صحة البريد الإلكتروني وكلمة المرور.',
            'Please check your email and password.',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          final completed = state.user?.preferencesCompleted ?? false;
          context.go(
            completed ? AppRoutes.home : AppRoutes.careerPreferences,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            actions: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: SettingsQuickActions(),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.loginTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.loginSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.68),
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
                      textInputAction: TextInputAction.done,
                      enabled: !state.isLoading,
                      validator: (v) => AppValidators.password(context, v),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                context.read<AuthCubit>().clearStatus();
                                context.push(AppRoutes.forgotPassword);
                              },
                        child: Text(strings.forgotPassword),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: strings.loginButton,
                      isLoading: state.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 24),
                    SocialAuthButtons(
                      enabled: !state.isLoading,
                      onGooglePressed: () =>
                          context.read<AuthCubit>().loginWithGoogle(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(strings.noAccount),
                        TextButton(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  context.read<AuthCubit>().clearStatus();
                                  context.push(AppRoutes.signUp);
                                },
                          child: Text(
                            strings.createAccount,
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
