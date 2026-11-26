import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/local_storage_service.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';
import 'auth_state.dart';

/// Handles Firebase authentication flows and syncs session state.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._authRepository,
    this._storage,
  ) : super(_initialState(_authRepository, _storage)) {
    _authSubscription = _authRepository.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  final AuthRepository _authRepository;
  final LocalStorageService _storage;
  StreamSubscription<User?>? _authSubscription;
  int _sessionSyncVersion = 0;

  static AuthState _initialState(
    AuthRepository authRepository,
    LocalStorageService storage,
  ) {
    final currentUser = authRepository.currentUser;
    if (currentUser != null) {
      return AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(
          uid: currentUser.uid,
          name: currentUser.displayName ?? storage.userName ?? 'DEPI User',
          email: currentUser.email ?? storage.userEmail ?? '',
          preferencesCompleted: storage.userUid == currentUser.uid &&
              storage.getCareerPreferencesJson() != null,
        ),
      );
    }
    return const AuthState();
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (isClosed) return;

    if (firebaseUser == null) {
      if (state.user != null ||
          state.status == AuthStatus.authenticated ||
          state.status == AuthStatus.registered) {
        _sessionSyncVersion++;
        await _storage.clearUserSession();
        if (!isClosed) {
          emit(const AuthState(status: AuthStatus.loggedOut));
        }
      }
      return;
    }

    if (state.user?.uid == firebaseUser.uid) return;
    try {
      final profile = await _authRepository.getUserProfile(firebaseUser.uid);
      if (isClosed || _authRepository.currentUser?.uid != firebaseUser.uid) {
        return;
      }

      final user = profile ??
          UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ??
                storageNameFallback(firebaseUser.email),
            email: firebaseUser.email ?? '',
          );
      await _syncLocalSession(user);
      if (!isClosed && _authRepository.currentUser?.uid == firebaseUser.uid) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      }
    } catch (_) {
      // Keep current state if Firestore profile fetch fails transiently.
    }
  }

  String storageNameFallback(String? email) {
    if (_storage.userName != null && _storage.userName!.isNotEmpty) {
      return _storage.userName!;
    }
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'DEPI User';
  }

  Future<void> _syncLocalSession(UserModel user) async {
    final version = ++_sessionSyncVersion;
    final currentUid = _authRepository.currentUser?.uid;
    if (currentUid != null && currentUid != user.uid) return;
    if (_storage.userUid != null && _storage.userUid != user.uid) {
      await _storage.clearCareerPreferencesJson();
    }
    if (version != _sessionSyncVersion) return;
    await _storage.saveUserSession(
      name: user.name.isNotEmpty ? user.name : 'DEPI User',
      email: user.email,
      uid: user.uid,
    );
    if (version != _sessionSyncVersion) return;
    if (user.careerPreferences != null) {
      await _storage.saveCareerPreferencesJson(
        user.careerPreferences!.toJson(),
      );
    } else {
      await _storage.clearCareerPreferencesJson();
    }
  }

  void clearStatus() {
    emit(state.copyWith(status: AuthStatus.initial, errorMessage: null));
  }

  Future<void> login({
    required String email,
    required String password,
    required String invalidCredentialsMessage,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      await _syncLocalSession(user);
      if (isClosed) return;

      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: AuthRepository.mapFirebaseAuthError(e),
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: invalidCredentialsMessage,
        ),
      );
    }
  }

  Future<void> loginWithGoogle({
    String genericErrorMessage =
        'تعذر تسجيل الدخول عبر حساب Google. حاول مرة أخرى.',
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await _authRepository.signInWithGoogle();
      if (isClosed) return;

      if (user == null) {
        emit(state.copyWith(status: AuthStatus.initial, errorMessage: null));
        return;
      }

      await _syncLocalSession(user);
      if (isClosed) return;

      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: AuthRepository.mapFirebaseAuthError(e),
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: genericErrorMessage,
        ),
      );
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String genericErrorMessage,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await _authRepository.signUpWithEmail(
        fullName: fullName,
        email: email,
        password: password,
      );
      await _syncLocalSession(user);
      if (isClosed) return;

      emit(
        AuthState(
          status: AuthStatus.registered,
          user: user,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: AuthRepository.mapFirebaseAuthError(e),
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: genericErrorMessage,
        ),
      );
    }
  }

  Future<void> sendPasswordResetLink({
    required String email,
    required String genericErrorMessage,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final normalizedEmail = email.trim();
      await _authRepository.sendPasswordResetEmail(normalizedEmail);
      if (isClosed) return;

      emit(
        state.copyWith(
          status: AuthStatus.resetLinkSent,
          resetEmail: normalizedEmail,
          errorMessage: null,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: AuthRepository.mapFirebaseAuthError(e),
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: genericErrorMessage,
        ),
      );
    }
  }

  Future<void> resetPassword({
    required String newPassword,
    required String genericErrorMessage,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                'يرجى فتح رابط إعادة التعيين المرسل إلى بريدك الإلكتروني.',
          ),
        );
        return;
      }
      await currentUser.updatePassword(newPassword);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.passwordResetSuccess,
          errorMessage: null,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: AuthRepository.mapFirebaseAuthError(e),
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: genericErrorMessage,
        ),
      );
    }
  }

  Future<void> signOut() async {
    _sessionSyncVersion++;
    await _authRepository.signOut();
    await _storage.clearUserSession();
    if (isClosed) return;
    emit(const AuthState(status: AuthStatus.loggedOut));
  }

  Future<void> logout() => signOut();

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
