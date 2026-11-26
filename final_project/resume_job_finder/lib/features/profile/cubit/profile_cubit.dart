import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resume_matching/models/resume_analysis_model.dart';
import 'profile_state.dart';

/// Manages user profile, targetRole/preferredSkills, and latest analysis summary in Firestore.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        super(const ProfileState());

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Future<void> loadProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'لم يتم العثور على مستخدم مسجل.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data() ?? const <String, dynamic>{};

      final rawSkills = data['preferredSkills'];
      final parsedSkills = rawSkills is List
          ? rawSkills
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : <String>[];

      ResumeAnalysisModel? latestAnalysis;
      final rawAnalysis = data['latestResumeAnalysis'];
      if (rawAnalysis is Map<String, dynamic>) {
        latestAnalysis = ResumeAnalysisModel.fromJson(rawAnalysis);
      }

      final prefsMap = data['careerPreferences'];
      final fallbackTrack = prefsMap is Map<String, dynamic>
          ? (prefsMap['track'] as String?) ?? ''
          : '';
      final fallbackCity = prefsMap is Map<String, dynamic>
          ? (prefsMap['preferredCity'] as String?) ?? ''
          : '';

      if (isClosed) return;
      emit(
        ProfileState(
          status: ProfileStatus.loaded,
          uid: user.uid,
          fullName:
              (data['fullName'] as String?) ?? user.displayName ?? 'DEPI User',
          email: (data['email'] as String?) ?? user.email ?? '',
          targetRole: (data['targetRole'] as String?) ?? fallbackTrack,
          city: (data['city'] as String?) ?? fallbackCity,
          preferredSkills: parsedSkills,
          latestAnalysis: latestAnalysis,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          uid: user.uid,
          fullName: user.displayName ?? 'DEPI User',
          email: user.email ?? '',
          errorMessage: 'تعذر تحميل بيانات الحساب من السحابة.',
        ),
      );
    }
  }

  Future<void> updateProfileInfo({
    required String fullName,
    required String targetRole,
    required String city,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    final normalizedName = fullName.trim();
    final normalizedRole = targetRole.trim();
    final normalizedCity = city.trim();

    emit(state.copyWith(status: ProfileStatus.saving, errorMessage: null));
    try {
      if (normalizedName.isNotEmpty) {
        await user.updateDisplayName(normalizedName);
      }
      await _firestore.collection('users').doc(user.uid).set(
        {
          'fullName': normalizedName,
          'targetRole': normalizedRole,
          'city': normalizedCity,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.saved,
          fullName: normalizedName,
          targetRole: normalizedRole,
          city: normalizedCity,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'تعذر حفظ التعديلات في Firestore.',
        ),
      );
    }
  }

  Future<void> saveMatchingPreferences({
    required String targetRole,
    required String preferredSkillsRaw,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    final normalizedRole = targetRole.trim();
    final skills = preferredSkillsRaw
        .split(RegExp(r'[,،\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    emit(state.copyWith(status: ProfileStatus.saving, errorMessage: null));
    try {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'targetRole': normalizedRole,
          'preferredSkills': skills,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.saved,
          targetRole: normalizedRole,
          preferredSkills: skills,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'تعذر حفظ التفضيلات في Firestore.',
        ),
      );
    }
  }
}
