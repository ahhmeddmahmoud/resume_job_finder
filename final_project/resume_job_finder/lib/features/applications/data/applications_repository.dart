import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../resume_matching/models/resume_analysis_model.dart';
import '../models/job_application_model.dart';

/// Persists job applications under `users/{uid}/applications`.
class ApplicationsRepository {
  ApplicationsRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _appsRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('applications');
  }

  Future<List<JobApplicationModel>> getApplications() async {
    final ref = _appsRef;
    if (ref == null) return const [];
    final snapshot = await ref
        .orderBy('appliedAt', descending: true)
        .get()
        .timeout(const Duration(seconds: 8));
    return snapshot.docs
        .map((doc) => JobApplicationModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  Future<JobApplicationModel> submitApplication(JobMatchModel job) async {
    final uid = _uid;
    final ref = _appsRef;
    if (uid == null || ref == null) {
      throw StateError('يجب تسجيل الدخول للتقديم على الوظيفة.');
    }

    final now = DateTime.now();
    final docRef = await ref.add({
      if (job.id != null) 'jobId': job.id,
      'title': job.title,
      'company': job.companyType,
      'jobTitle': job.title,
      'companyType': job.companyType,
      'location': job.location,
      'workType': job.workType,
      'matchPercentage': job.matchPercentage,
      if (job.applyUrl != null) 'applyUrl': job.applyUrl,
      'status': ApplicationStatus.applied.name,
      'appliedAt': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 12));

    // A notification failure must not hide a successfully stored application.
    final notificationWrite = _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .add({
      'title': 'تم إرسال طلب التوظيف',
      'body': 'تم تسجيل طلبك لوظيفة ${job.title} بنجاح.',
      'type': 'application',
      'targetRoute': '/applications',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    }).then<void>((_) {}, onError: (Object _) {});
    unawaited(notificationWrite);

    return JobApplicationModel(
      id: docRef.id,
      jobTitle: job.title,
      companyType: job.companyType,
      location: job.location,
      workType: job.workType,
      matchPercentage: job.matchPercentage,
      status: ApplicationStatus.applied,
      appliedAt: now,
      applyUrl: job.applyUrl,
    );
  }
}
