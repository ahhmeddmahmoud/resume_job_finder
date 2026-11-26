import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/applications/cubit/applications_cubit.dart';
import '../../features/applications/data/applications_repository.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/career_preferences/cubit/career_preferences_cubit.dart';
import '../../features/jobs/cubit/saved_jobs_cubit.dart';
import '../../features/jobs/data/jsearch_jobs_repository.dart';
import '../../features/jobs/data/jobs_repository.dart';
import '../../features/notifications/cubit/notifications_cubit.dart';
import '../../features/onboarding/cubit/onboarding_cubit.dart';
import '../../features/profile/cubit/profile_cubit.dart';
import '../../features/resume_matching/cubit/resume_matching_cubit.dart';
import '../../features/resume_matching/data/resume_matching_repository.dart';
import '../../features/resume_matching/services/gemini_resume_service.dart';
import '../../features/resume_matching/services/local_resume_analyzer.dart';
import '../../features/resume_matching/services/pdf_text_extractor_service.dart';
import '../../features/splash/cubit/splash_cubit.dart';
import '../settings/app_settings_cubit.dart';
import '../storage/local_storage_service.dart';

final GetIt sl = GetIt.instance;

/// Initializes core services, Firebase instances, repositories, and Cubits in [GetIt].
Future<void> initDependencies() async {
  if (sl.isRegistered<SharedPreferences>()) return;

  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(sl<SharedPreferences>()),
  );

  // Firebase & Auth Services
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  // Resume Matching, Jobs & Applications Repositories/Services
  sl.registerLazySingleton<PdfTextExtractorService>(
    () => PdfTextExtractorService(),
  );
  sl.registerLazySingleton<LocalResumeAnalyzer>(
    () => const LocalResumeAnalyzer(),
  );
  sl.registerLazySingleton<GeminiResumeService>(
    () => GeminiResumeService(
      localAnalyzer: sl<LocalResumeAnalyzer>(),
    ),
  );
  sl.registerLazySingleton<ResumeMatchingRepository>(
    () => ResumeMatchingRepository(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
      storage: sl<LocalStorageService>(),
    ),
  );
  sl.registerLazySingleton<JSearchJobsRepository>(
    () => JSearchJobsRepository(),
  );
  sl.registerLazySingleton<JobsRepository>(
    () => JobsRepository(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  sl.registerLazySingleton<ApplicationsRepository>(
    () => ApplicationsRepository(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // App-wide Cubits
  sl.registerLazySingleton<AppSettingsCubit>(
    () => AppSettingsCubit(sl<LocalStorageService>()),
  );
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      sl<AuthRepository>(),
      sl<LocalStorageService>(),
    ),
  );
  sl.registerLazySingleton<ResumeMatchingCubit>(
    () => ResumeMatchingCubit(
      pdfExtractor: sl<PdfTextExtractorService>(),
      geminiService: sl<GeminiResumeService>(),
      repository: sl<ResumeMatchingRepository>(),
      jobsRepository: sl<JSearchJobsRepository>(),
      firebaseAuth: sl<FirebaseAuth>(),
    )..loadLatestAnalysis(),
  );
  sl.registerLazySingleton<SavedJobsCubit>(
    () => SavedJobsCubit(sl<JobsRepository>(), sl<FirebaseAuth>())
      ..loadSavedJobs(),
  );
  sl.registerLazySingleton<ApplicationsCubit>(
    () => ApplicationsCubit(
      sl<ApplicationsRepository>(),
      sl<FirebaseAuth>(),
    )..loadApplications(),
  );

  // Screen-scoped Cubits
  sl.registerFactory<SplashCubit>(
    () => SplashCubit(
      sl<LocalStorageService>(),
      authRepository: sl<AuthRepository>(),
    ),
  );
  sl.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(sl<LocalStorageService>()),
  );
  sl.registerFactory<CareerPreferencesCubit>(
    () => CareerPreferencesCubit(
      sl<LocalStorageService>(),
      authRepository: sl<AuthRepository>(),
    ),
  );
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  sl.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
}
