import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../resume_matching/models/resume_analysis_model.dart';

/// Persists user's saved jobs under `users/{uid}/saved_jobs`.
class JobsRepository {
  JobsRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _savedRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('saved_jobs');
  }

  String jobDocId(JobMatchModel job) {
    final externalId = job.id?.trim();
    if (externalId != null && externalId.isNotEmpty) {
      return Uri.encodeComponent(externalId);
    }
    final raw = '${job.title}_${job.location}_${job.workType}'.trim();
    return Uri.encodeComponent(raw);
  }

  Future<List<JobMatchModel>> getSavedJobs() async {
    final ref = _savedRef;
    if (ref == null) return const [];
    final snapshot = await ref
        .orderBy('savedAt', descending: true)
        .get()
        .timeout(const Duration(seconds: 8));
    return snapshot.docs
        .map((doc) => JobMatchModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> saveJob(JobMatchModel job) async {
    final ref = _savedRef;
    if (ref == null) return;
    await ref.doc(jobDocId(job)).set({
      ...job.toJson(),
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeSavedJob(JobMatchModel job) async {
    final ref = _savedRef;
    if (ref == null) return;
    await ref.doc(jobDocId(job)).delete();
  }
}
