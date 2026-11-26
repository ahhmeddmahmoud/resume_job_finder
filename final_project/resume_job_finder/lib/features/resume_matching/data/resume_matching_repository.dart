import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../career_preferences/models/career_preferences_model.dart';
import '../models/resume_analysis_model.dart';

/// Reads user career preferences and persists CV analysis results in Firestore.
class ResumeMatchingRepository {
  ResumeMatchingRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required LocalStorageService storage,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _storage = storage;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final LocalStorageService _storage;

  String? get currentUid => _firebaseAuth.currentUser?.uid;

  Future<CareerPreferencesModel?> getUserCareerPreferences() async {
    final uid = currentUid;
    if (uid != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 5));
        final data = doc.data();
        final rawPrefs = data?['careerPreferences'];
        if (rawPrefs is Map<String, dynamic>) {
          return CareerPreferencesModel.fromJson(
              _withDefaultSearchLocation(rawPrefs));
        }
      } catch (_) {
        // The UID-scoped local copy remains usable when Firestore is offline.
      }
    }

    final localJson = _storage.getCareerPreferencesJson();
    if (localJson != null && (uid == null || _storage.userUid == uid)) {
      return CareerPreferencesModel.fromJson(
          _withDefaultSearchLocation(localJson));
    }
    return null;
  }

  Map<String, dynamic> _withDefaultSearchLocation(Map<String, dynamic> json) {
    final location = json['preferredCity'];
    if (location is String && location.trim().isNotEmpty) return json;
    return {...json, 'preferredCity': 'Egypt'};
  }

  Future<void> saveAnalysisResult(ResumeAnalysisModel analysis) async {
    final uid = currentUid;
    if (uid == null) return;

    final payload = analysis.toJson();
    try {
      await _firestore.collection('users').doc(uid).set(
        {
          'latestResumeAnalysis': payload,
          'matchPercentage': analysis.matchPercentage,
          'matchedSkills': analysis.matchedSkills,
          'missingSkills': analysis.missingSkills,
          'recommendedJobs':
              analysis.recommendedJobs.map((j) => j.toJson()).toList(),
          'analyzedAt': FieldValue.serverTimestamp(),
          'lastAnalyzedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ).timeout(const Duration(seconds: 8));
    } catch (_) {
      // Keep local analysis usable if the cloud write is unavailable or slow.
    }

    final notificationWrite = _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .add({
      'title': 'اكتمل تحليل سيرتك الذاتية',
      'body':
          'تم تحليل ${analysis.fileName} بنسبة توافق ${analysis.matchPercentage}% وترشيح ${analysis.recommendedJobs.length} وظائف.',
      'type': 'analysis',
      'targetRoute': '/cv-analysis-results',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    }).then<void>((_) {}, onError: (Object _) {});
    unawaited(notificationWrite);
  }

  Future<ResumeAnalysisModel?> getLatestAnalysisResult() async {
    final uid = currentUid;
    if (uid == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .timeout(const Duration(seconds: 8));
    final data = doc.data();
    final rawAnalysis = data?['latestResumeAnalysis'];
    if (rawAnalysis is Map<String, dynamic>) {
      return ResumeAnalysisModel.fromJson(rawAnalysis);
    }
    return null;
  }

  Future<void> clearAnalysisResult() async {
    final uid = currentUid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set(
      {
        'latestResumeAnalysis': FieldValue.delete(),
        'matchPercentage': FieldValue.delete(),
        'matchedSkills': FieldValue.delete(),
        'missingSkills': FieldValue.delete(),
        'recommendedJobs': FieldValue.delete(),
        'analyzedAt': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );
  }
}
