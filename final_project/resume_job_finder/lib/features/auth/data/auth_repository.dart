import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../career_preferences/models/career_preferences_model.dart';
import '../models/user_model.dart';

/// Repository encapsulating Firebase Auth, Google Sign-In, and Cloud Firestore
/// user profile & career preferences persistence.
class AuthRepository {
  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserModel> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedName = fullName.trim();
    final normalizedEmail = email.trim();

    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-creation-failed',
        message: 'تعذّر إنشاء الحساب.',
      );
    }

    await user.updateDisplayName(normalizedName);
    await user.reload();

    await _usersRef.doc(user.uid).set({
      'uid': user.uid,
      'fullName': normalizedName,
      'email': normalizedEmail,
      'createdAt': FieldValue.serverTimestamp(),
      'preferencesCompleted': false,
    });

    return UserModel(
      uid: user.uid,
      name: normalizedName,
      email: normalizedEmail,
      preferencesCompleted: false,
      createdAt: DateTime.now(),
    );
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'تعذّر تسجيل الدخول.',
      );
    }

    return _ensureUserDocument(user);
  }

  /// Signs in using Google. Returns `null` if the user cancels the picker.
  Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'تعذّر تسجيل الدخول عبر Google.',
      );
    }

    return _ensureUserDocument(
      user,
      fallbackName: googleUser.displayName,
      fallbackEmail: googleUser.email,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc =
        await _usersRef.doc(uid).get().timeout(const Duration(seconds: 8));
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return UserModel.fromMap(data, uid: uid);
  }

  Future<bool> isPreferencesCompleted(String uid) async {
    final doc =
        await _usersRef.doc(uid).get().timeout(const Duration(seconds: 8));
    final data = doc.data();
    if (!doc.exists || data == null) return false;
    return (data['preferencesCompleted'] as bool?) ?? false;
  }

  Future<void> saveCareerPreferences({
    required String uid,
    required CareerPreferencesModel preferences,
  }) async {
    await _usersRef.doc(uid).set(
      {
        'preferencesCompleted': true,
        'careerPreferences': preferences.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    ).timeout(const Duration(seconds: 10));
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore if user was not signed in via Google.
    }
    await _firebaseAuth.signOut();
  }

  Future<UserModel> _ensureUserDocument(
    User user, {
    String? fallbackName,
    String? fallbackEmail,
  }) async {
    final docRef = _usersRef.doc(user.uid);
    final doc = await docRef.get();
    final existingData = doc.data();

    if (doc.exists && existingData != null) {
      return UserModel.fromMap(existingData, uid: user.uid);
    }

    final email = user.email ?? fallbackEmail ?? '';
    final displayName = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : (fallbackName?.trim().isNotEmpty ?? false)
            ? fallbackName!.trim()
            : (email.contains('@') ? email.split('@').first : 'DEPI User');

    await docRef.set({
      'uid': user.uid,
      'fullName': displayName,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'preferencesCompleted': false,
    });

    return UserModel(
      uid: user.uid,
      name: displayName,
      email: email,
      preferencesCompleted: false,
      createdAt: DateTime.now(),
    );
  }

  /// Maps [FirebaseAuthException] codes to clear Arabic messages.
  static String mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد حساب مسجل بهذا البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة، يجب أن تكون 6 أحرف على الأقل.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم.';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح به مؤقتًا. حاول لاحقًا.';
      case 'network-request-failed':
        return 'تعذر الاتصال بالشبكة. تحقق من اتصال الإنترنت.';
      case 'operation-not-allowed':
        return 'طريقة تسجيل الدخول هذه غير مفعلة حاليًا.';
      case 'requires-recent-login':
        return 'يرجى إعادة تسجيل الدخول لإتمام هذا الإجراء.';
      case 'account-exists-with-different-credential':
        return 'يوجد حساب مرتبط بهذا البريد بطريقة تسجيل دخول أخرى.';
      default:
        return 'حدث خطأ أثناء المصادقة (${e.code}). حاول مرة أخرى.';
    }
  }
}
