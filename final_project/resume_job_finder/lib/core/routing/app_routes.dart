class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String careerPreferences = '/career-preferences';

  // 5-Tab Shell Routes
  static const String home = '/home';
  static const String jobs = '/jobs';
  static const String savedJobs = '/saved-jobs';
  static const String applications = '/applications';
  static const String profile = '/profile';

  // CV Flow Routes
  static const String uploadCv = '/upload-cv';
  static const String cvManagement = '/cv-management';
  static const String cvAnalysisLoading = '/cv-analysis-loading';
  static const String cvAnalysisResults = '/cv-analysis-results';

  // Jobs & Applications Sub-routes
  static const String jobDetails = '/job-details';
  static const String applyConfirmation = '/apply-confirmation';
  static const String applicationDetails = '/application-details';

  // Profile & Settings Sub-routes
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String privacySecurity = '/privacy-security';
}
