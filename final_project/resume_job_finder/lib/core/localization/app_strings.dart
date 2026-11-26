import 'package:material_ui/material_ui.dart';

/// Simple bilingual (Arabic / English) string helper.
/// Uses the active [Locale] from [Localizations.localeOf(context)].
class AppStrings {
  AppStrings._(this.isArabic);

  final bool isArabic;

  static AppStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return AppStrings._(code == 'ar');
  }

  String tr(String ar, String en) => isArabic ? ar : en;

  // App
  String get appName => tr('مطابق السيرة والوظائف', 'Resume & Job Finder');
  String get appTagline => tr(
        'حلّل سيرتك الذاتية واعثر على الوظيفة الأنسب لمهاراتك',
        'Analyze your CV and discover jobs tailored to your skills',
      );

  // Common
  String get next => tr('التالي', 'Next');
  String get skip => tr('تخطي', 'Skip');
  String get getStarted => tr('ابدأ الآن', 'Get Started');
  String get saveAndContinue => tr('حفظ والمتابعة', 'Save & Continue');
  String get loading => tr('جاري التحميل...', 'Loading...');
  String get backToLogin => tr('العودة لتسجيل الدخول', 'Back to Login');
  String get switchLanguage => tr('English', 'العربية');

  // Onboarding
  String get onboardingTitle1 => tr(
        'سيرتك الذاتية هي بداية فرصتك',
        'Your CV Is the Start of Your Opportunity',
      );
  String get onboardingDesc1 => tr(
        'ارفع سيرتك الذاتية بسهولة ودع النظام يحلل خبراتك ومشروعاتك بدقة.',
        'Upload your resume easily and let the system analyze your experience and projects accurately.',
      );
  String get onboardingTitle2 => tr(
        'اعرف نقاط قوتك ومهاراتك',
        'Know Your Strengths and Skills',
      );
  String get onboardingDesc2 => tr(
        'اكتشف المهارات المطلوبة في سوق العمل وسد الفجوات المهنية بثقة.',
        'Discover in-demand market skills and bridge your career gaps with confidence.',
      );
  String get onboardingTitle3 => tr(
        'وظيفتك المناسبة أقرب مما تتخيل',
        'Your Right Job Is Closer Than You Think',
      );
  String get onboardingDesc3 => tr(
        'احصل على ترشيحات وظائف مخصصة تناسب تخصصك ومستوى خبرتك ومدينتك.',
        'Get personalized job recommendations matching your track, experience, and preferred city.',
      );

  // Auth - Login
  String get loginTitle => tr('تسجيل الدخول', 'Welcome Back');
  String get loginSubtitle => tr(
        'سجّل دخولك للمتابعة إلى فرصك الوظيفية',
        'Sign in to continue to your career opportunities',
      );
  String get emailLabel => tr('البريد الإلكتروني', 'Email Address');
  String get emailHint => tr('example@domain.com', 'example@domain.com');
  String get passwordLabel => tr('كلمة المرور', 'Password');
  String get passwordHint => tr('••••••••', '••••••••');
  String get forgotPassword => tr('نسيت كلمة المرور؟', 'Forgot Password?');
  String get loginButton => tr('تسجيل الدخول', 'Sign In');
  String get orContinueWith => tr('أو المتابعة عبر', 'Or continue with');
  String get continueWithGoogle =>
      tr('المتابعة عبر Google', 'Continue with Google');
  String get noAccount => tr('ليس لديك حساب؟', "Don't have an account?");
  String get createAccount => tr('إنشاء حساب', 'Create Account');
  String get socialComingSoon => tr(
        'سيتم تفعيل تسجيل الدخول الاجتماعي في المرحلة القادمة.',
        'Social sign-in will be enabled in the next phase.',
      );

  // Auth - Sign Up
  String get signUpTitle => tr('إنشاء حساب جديد', 'Create Account');
  String get signUpSubtitle => tr(
        'أنشئ حسابك لتخصيص تفضيلاتك المهنية والوظيفية',
        'Create your account to personalize your career preferences',
      );
  String get fullNameLabel => tr('الاسم الكامل', 'Full Name');
  String get fullNameHint => tr('أحمد محمد علي', 'Ahmed Mohamed Ali');
  String get confirmPasswordLabel =>
      tr('تأكيد كلمة المرور', 'Confirm Password');
  String get acceptTerms => tr(
        'أوافق على الشروط والأحكام وسياسة الخصوصية',
        'I agree to the Terms & Conditions and Privacy Policy',
      );
  String get termsRequiredError => tr(
        'يجب الموافقة على الشروط والأحكام للمتابعة.',
        'You must accept the Terms & Conditions to continue.',
      );
  String get alreadyHaveAccount =>
      tr('لديك حساب بالفعل؟', 'Already have an account?');

  // Auth - Forgot & Reset Password
  String get forgotPasswordTitle =>
      tr('استرجاع كلمة المرور', 'Forgot Password');
  String get forgotPasswordSubtitle => tr(
        'أدخل بريدك الإلكتروني المسجل وسنرسل لك رابط إعادة التعيين.',
        'Enter your registered email and we will send you a reset link.',
      );
  String get sendResetLink => tr('إرسال رابط الاسترجاع', 'Send Reset Link');
  String get resetLinkSentSuccess => tr(
        'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.',
        'A password reset link has been sent to your email address.',
      );
  String get proceedToReset => tr('تعيين كلمة مرور جديدة', 'Set New Password');

  String get resetPasswordTitle =>
      tr('تعيين كلمة مرور جديدة', 'Reset Password');
  String get resetPasswordSubtitle => tr(
        'اختر كلمة مرور قوية لحماية حسابك.',
        'Choose a strong password to protect your account.',
      );
  String get newPasswordLabel => tr('كلمة المرور الجديدة', 'New Password');
  String get resetPasswordButton => tr('حفظ كلمة المرور', 'Save Password');
  String get resetPasswordSuccess => tr(
        'تم تحديث كلمة المرور بنجاح. يمكنك تسجيل الدخول الآن.',
        'Password updated successfully. You can now sign in.',
      );

  // Career Preferences
  String get preferencesTitle => tr('التفضيلات المهنية', 'Career Preferences');
  String get preferencesSubtitle => tr(
        'اختر مسارك البرمجي وخبرتك لنرشح لك الوظائف الأنسب.',
        'Select your software track and experience for better job matches.',
      );
  String get trackLabel => tr('التخصص البرمجي', 'Programming Track');
  String get experienceLevelLabel => tr('مستوى الخبرة', 'Experience Level');
  String get experienceYearsLabel => tr('سنوات الخبرة', 'Years of Experience');
  String get workTypeLabel => tr('نوع العمل', 'Work Type');
  String get preferredCityLabel => tr('المدينة المفضلة', 'Preferred City');
  String get yearsUnit => tr('سنوات', 'years');
  String get preferencesValidationError => tr(
        'يرجى استكمال جميع التفضيلات المطلوبة قبل المتابعة.',
        'Please complete all required preferences before continuing.',
      );

  // Home Placeholder
  String get homePlaceholderTitle =>
      tr('الرئيسية (معاينة مبدئية)', 'Home (Placeholder)');
  String get homePlaceholderSubtitle => tr(
        'تم إكمال شاشات البداية والمصادقة والتفضيلات بنجاح.',
        'Splash, Onboarding, Auth, and Preferences flow completed successfully.',
      );
  String get logout => tr('تسجيل الخروج', 'Sign Out');
  String get editPreferences => tr('تعديل التفضيلات', 'Edit Preferences');
  String get noPreferencesSaved => tr(
        'لا توجد تفضيلات محفوظة بعد.',
        'No career preferences saved yet.',
      );
}
