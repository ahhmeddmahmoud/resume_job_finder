import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resume_matching/models/resume_analysis_model.dart';
import '../data/jobs_repository.dart';

bool _sameJob(JobMatchModel first, JobMatchModel second) {
  if (first.id != null && second.id != null) return first.id == second.id;
  return first.title == second.title &&
      first.companyType == second.companyType &&
      first.location == second.location &&
      first.workType == second.workType;
}

enum SavedJobsStatus { initial, loading, loaded, error }

class SavedJobsState extends Equatable {
  const SavedJobsState({
    this.status = SavedJobsStatus.initial,
    this.savedJobs = const [],
    this.errorMessage,
  });

  final SavedJobsStatus status;
  final List<JobMatchModel> savedJobs;
  final String? errorMessage;

  bool isSaved(JobMatchModel job) {
    return savedJobs.any((saved) => _sameJob(saved, job));
  }

  SavedJobsState copyWith({
    SavedJobsStatus? status,
    List<JobMatchModel>? savedJobs,
    String? errorMessage,
  }) {
    return SavedJobsState(
      status: status ?? this.status,
      savedJobs: savedJobs ?? this.savedJobs,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, savedJobs, errorMessage];
}

class SavedJobsCubit extends Cubit<SavedJobsState> {
  SavedJobsCubit(this._repository, this._firebaseAuth)
      : super(const SavedJobsState()) {
    _activeUid = _firebaseAuth.currentUser?.uid;
    _authSubscription = _firebaseAuth.authStateChanges().listen(_onAuthChanged);
  }

  final JobsRepository _repository;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _authSubscription;
  String? _activeUid;

  void _onAuthChanged(User? user) {
    final uid = user?.uid;
    if (uid == _activeUid) return;
    _activeUid = uid;
    if (uid == null) {
      emit(const SavedJobsState(status: SavedJobsStatus.loaded));
      return;
    }
    emit(const SavedJobsState(status: SavedJobsStatus.loading));
    unawaited(loadSavedJobs());
  }

  Future<void> loadSavedJobs() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      if (!isClosed) {
        emit(const SavedJobsState(status: SavedJobsStatus.loaded));
      }
      return;
    }
    _activeUid = uid;
    emit(state.copyWith(status: SavedJobsStatus.loading, errorMessage: null));
    try {
      final list = await _repository.getSavedJobs();
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return;
      emit(SavedJobsState(status: SavedJobsStatus.loaded, savedJobs: list));
    } catch (_) {
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return;
      emit(
        state.copyWith(
          status: SavedJobsStatus.error,
          errorMessage: 'تعذر تحميل الوظائف المحفوظة.',
        ),
      );
    }
  }

  Future<void> toggleSave(JobMatchModel job) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;
    final currentlySaved = state.isSaved(job);
    final updated = List<JobMatchModel>.from(state.savedJobs);
    if (currentlySaved) {
      updated.removeWhere((saved) => _sameJob(saved, job));
    } else {
      updated.insert(0, job);
    }

    emit(SavedJobsState(status: SavedJobsStatus.loaded, savedJobs: updated));
    try {
      if (currentlySaved) {
        await _repository.removeSavedJob(job);
      } else {
        await _repository.saveJob(job);
      }
      if (_firebaseAuth.currentUser?.uid != uid) return;
    } catch (_) {
      // Revert on failure
      if (_firebaseAuth.currentUser?.uid == uid) await loadSavedJobs();
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await super.close();
  }
}
