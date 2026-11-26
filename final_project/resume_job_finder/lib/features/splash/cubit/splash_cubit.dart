import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../auth/data/auth_repository.dart';
import 'splash_state.dart';

/// Checks onboarding, Firebase Auth session, and Firestore preferences status on startup.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._storage, {
    AuthRepository? authRepository,
    this.delay = const Duration(milliseconds: 1400),
  })  : _authRepository = authRepository,
        super(const SplashState());

  final LocalStorageService _storage;
  final AuthRepository? _authRepository;
  final Duration delay;

  Future<void> checkAppEntry() async {
    emit(const SplashState(isChecking: true));
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (isClosed) return;

    final onboardingDone = _storage.isOnboardingCompleted;
    if (!onboardingDone) {
      emit(
        const SplashState(
          isChecking: false,
          destination: SplashDestination.onboarding,
        ),
      );
      return;
    }

    final currentUser = _authRepository?.currentUser;
    if (currentUser == null) {
      if (_authRepository == null && _storage.isLoggedIn) {
        emit(
          const SplashState(
            isChecking: false,
            destination: SplashDestination.home,
          ),
        );
        return;
      }
      emit(
        const SplashState(
          isChecking: false,
          destination: SplashDestination.login,
        ),
      );
      return;
    }

    var preferencesCompleted = _storage.userUid == currentUser.uid &&
        _storage.getCareerPreferencesJson() != null;
    try {
      final profile = await _authRepository!.getUserProfile(currentUser.uid);
      if (profile != null) {
        preferencesCompleted = profile.preferencesCompleted;
        await _storage.saveUserSession(
          name: profile.name.isNotEmpty
              ? profile.name
              : (currentUser.displayName ?? 'DEPI User'),
          email: profile.email.isNotEmpty
              ? profile.email
              : (currentUser.email ?? ''),
          uid: currentUser.uid,
        );
        if (profile.careerPreferences != null) {
          await _storage.saveCareerPreferencesJson(
            profile.careerPreferences!.toJson(),
          );
        } else {
          await _storage.clearCareerPreferencesJson();
        }
      }
    } catch (_) {
      // Fallback to local preferences cache if offline or Firestore fails.
    }

    if (isClosed) return;

    emit(
      SplashState(
        isChecking: false,
        destination: preferencesCompleted
            ? SplashDestination.home
            : SplashDestination.careerPreferences,
      ),
    );
  }
}
