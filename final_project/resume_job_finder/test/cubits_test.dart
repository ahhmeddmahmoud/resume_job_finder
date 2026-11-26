import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/core/storage/local_storage_service.dart';
import 'package:resume_job_finder/features/auth/cubit/auth_cubit.dart';
import 'package:resume_job_finder/features/auth/cubit/auth_state.dart';
import 'package:resume_job_finder/features/auth/data/auth_repository.dart';
import 'package:resume_job_finder/features/auth/models/user_model.dart';
import 'package:resume_job_finder/features/career_preferences/cubit/career_preferences_cubit.dart';
import 'package:resume_job_finder/features/career_preferences/cubit/career_preferences_state.dart';
import 'package:resume_job_finder/features/career_preferences/models/career_preferences_model.dart';
import 'package:resume_job_finder/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:resume_job_finder/features/splash/cubit/splash_cubit.dart';
import 'package:resume_job_finder/features/splash/cubit/splash_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  UserModel? _storedUser;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<UserModel?> getUserProfile(String uid) async => _storedUser;

  @override
  Future<bool> isPreferencesCompleted(String uid) async =>
      _storedUser?.preferencesCompleted ?? false;

  @override
  Future<void> saveCareerPreferences({
    required String uid,
    required CareerPreferencesModel preferences,
  }) async {
    _storedUser = _storedUser?.copyWith(
      preferencesCompleted: true,
      careerPreferences: preferences,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _storedUser = UserModel(
      uid: 'test-uid',
      name: _storedUser?.name ?? email.split('@').first,
      email: email.trim(),
      preferencesCompleted: _storedUser?.preferencesCompleted ?? false,
    );
    return _storedUser!;
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    _storedUser = const UserModel(
      uid: 'google-uid',
      name: 'Google User',
      email: 'google@depi.com',
      preferencesCompleted: false,
    );
    return _storedUser;
  }

  @override
  Future<void> signOut() async {
    _storedUser = null;
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _storedUser = UserModel(
      uid: 'test-uid',
      name: fullName.trim(),
      email: email.trim(),
      preferencesCompleted: false,
    );
    return _storedUser!;
  }
}

void main() {
  late LocalStorageService storage;
  late _FakeAuthRepository fakeAuthRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = LocalStorageService(prefs);
    fakeAuthRepository = _FakeAuthRepository();
  });

  group('SplashCubit', () {
    test('navigates to onboarding when onboarding is not completed', () async {
      final cubit = SplashCubit(storage, delay: Duration.zero);
      await cubit.checkAppEntry();
      expect(cubit.state.isChecking, false);
      expect(cubit.state.destination, SplashDestination.onboarding);
      await cubit.close();
    });

    test('navigates to login when onboarding completed but not logged in',
        () async {
      await storage.setOnboardingCompleted(true);
      final cubit = SplashCubit(storage, delay: Duration.zero);
      await cubit.checkAppEntry();
      expect(cubit.state.destination, SplashDestination.login);
      await cubit.close();
    });

    test('navigates to home when onboarding completed and logged in', () async {
      await storage.setOnboardingCompleted(true);
      await storage.saveUserSession(name: 'Ali', email: 'ali@test.com');
      final cubit = SplashCubit(storage, delay: Duration.zero);
      await cubit.checkAppEntry();
      expect(cubit.state.destination, SplashDestination.home);
      await cubit.close();
    });
  });

  group('OnboardingCubit', () {
    test('updates page index and persists completion', () async {
      final cubit = OnboardingCubit(storage);
      cubit.onPageChanged(2);
      expect(cubit.state.currentPage, 2);
      expect(cubit.state.isLastPage, true);

      await cubit.completeOnboarding();
      expect(cubit.state.isCompleted, true);
      expect(storage.isOnboardingCompleted, true);
      await cubit.close();
    });
  });

  group('AuthCubit', () {
    test('login succeeds and saves session', () async {
      final cubit = AuthCubit(fakeAuthRepository, storage);
      await cubit.login(
        email: 'user@depi.com',
        password: 'password123',
        invalidCredentialsMessage: 'Invalid',
      );
      expect(cubit.state.status, AuthStatus.authenticated);
      expect(storage.isLoggedIn, true);
      expect(storage.userEmail, 'user@depi.com');
      await cubit.close();
    });

    test('signUp emits registered and saves user name', () async {
      final cubit = AuthCubit(fakeAuthRepository, storage);
      await cubit.signUp(
        fullName: 'Sara Ahmed',
        email: 'sara@depi.com',
        password: 'password123',
        genericErrorMessage: 'Error',
      );
      expect(cubit.state.status, AuthStatus.registered);
      expect(cubit.state.user?.name, 'Sara Ahmed');
      expect(storage.userName, 'Sara Ahmed');
      await cubit.close();
    });

    test('forgot password emits resetLinkSent', () async {
      final cubit = AuthCubit(fakeAuthRepository, storage);
      await cubit.sendPasswordResetLink(
        email: 'sara@depi.com',
        genericErrorMessage: 'Error',
      );
      expect(cubit.state.status, AuthStatus.resetLinkSent);
      await cubit.close();
    });
  });

  group('CareerPreferencesCubit', () {
    test('updates fields and persists to SharedPreferences', () async {
      final cubit = CareerPreferencesCubit(storage);
      cubit.selectTrack('Backend');
      cubit.selectExperienceLevel('Mid-Level');
      cubit.incrementYears();
      cubit.incrementYears();
      cubit.selectWorkType('Remote');
      cubit.selectCity('Alexandria');

      await cubit.savePreferences(validationError: 'Missing');

      expect(cubit.state.status, CareerPreferencesStatus.saved);
      final saved = storage.getCareerPreferencesJson();
      expect(saved?['track'], 'Backend');
      expect(saved?['experienceLevel'], 'Mid-Level');
      expect(saved?['experienceYears'], 3);
      expect(saved?['workType'], 'Remote');
      expect(saved?['preferredCity'], 'Alexandria');
      await cubit.close();
    });
  });
}
