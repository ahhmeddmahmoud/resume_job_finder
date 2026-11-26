import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../features/applications/models/job_application_model.dart';
import '../../features/applications/presentation/pages/application_details_page.dart';
import '../../features/applications/presentation/pages/applications_tracker_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/career_preferences/presentation/pages/career_preferences_page.dart';
import '../../features/home/presentation/pages/home_dashboard_page.dart';
import '../../features/jobs/presentation/pages/apply_confirmation_page.dart';
import '../../features/jobs/presentation/pages/job_details_page.dart';
import '../../features/jobs/presentation/pages/job_finder_page.dart';
import '../../features/jobs/presentation/pages/saved_jobs_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/resume_matching/models/resume_analysis_model.dart';
import '../../features/resume_matching/presentation/pages/cv_analysis_loading_page.dart';
import '../../features/resume_matching/presentation/pages/cv_analysis_results_page.dart';
import '../../features/resume_matching/presentation/pages/cv_management_page.dart';
import '../../features/resume_matching/presentation/pages/upload_cv_page.dart';
import '../../features/settings/presentation/pages/privacy_security_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../widgets/main_shell_scaffold.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static const Set<String> _publicRoutes = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.signUp,
    AppRoutes.forgotPassword,
  };

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (_publicRoutes.contains(location)) return null;

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null && location != AppRoutes.resetPassword) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.careerPreferences,
        builder: (context, state) => const CareerPreferencesPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeDashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.jobs,
                builder: (context, state) => const JobFinderPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.savedJobs,
                builder: (context, state) => const SavedJobsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.applications,
                builder: (context, state) => const ApplicationsTrackerPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.uploadCv,
        builder: (context, state) => const UploadCvPage(),
      ),
      GoRoute(
        path: AppRoutes.cvManagement,
        builder: (context, state) => const CvManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.cvAnalysisLoading,
        builder: (context, state) => const CvAnalysisLoadingPage(),
      ),
      GoRoute(
        path: AppRoutes.cvAnalysisResults,
        builder: (context, state) => const CvAnalysisResultsPage(),
      ),
      GoRoute(
        path: AppRoutes.jobDetails,
        builder: (context, state) {
          final job = state.extra as JobMatchModel;
          return JobDetailsPage(job: job);
        },
      ),
      GoRoute(
        path: AppRoutes.applyConfirmation,
        builder: (context, state) {
          final job = state.extra as JobMatchModel;
          return ApplyConfirmationPage(job: job);
        },
      ),
      GoRoute(
        path: AppRoutes.applicationDetails,
        builder: (context, state) {
          final application = state.extra as JobApplicationModel;
          return ApplicationDetailsPage(application: application);
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.privacySecurity,
        builder: (context, state) => const PrivacySecurityPage(),
      ),
    ],
  );
}
