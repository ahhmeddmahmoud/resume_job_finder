import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resume_matching/models/resume_analysis_model.dart';
import '../data/applications_repository.dart';
import '../models/job_application_model.dart';

enum ApplicationsStateStatus {
  initial,
  loading,
  loaded,
  submitting,
  submitted,
  error
}

class ApplicationsState extends Equatable {
  const ApplicationsState({
    this.status = ApplicationsStateStatus.initial,
    this.applications = const [],
    this.selectedFilter,
    this.lastSubmitted,
    this.errorMessage,
  });

  final ApplicationsStateStatus status;
  final List<JobApplicationModel> applications;
  final ApplicationStatus? selectedFilter;
  final JobApplicationModel? lastSubmitted;
  final String? errorMessage;

  List<JobApplicationModel> get filteredApplications {
    if (selectedFilter == null) return applications;
    return applications.where((a) => a.status == selectedFilter).toList();
  }

  ApplicationsState copyWith({
    ApplicationsStateStatus? status,
    List<JobApplicationModel>? applications,
    ApplicationStatus? selectedFilter,
    bool clearFilter = false,
    JobApplicationModel? lastSubmitted,
    String? errorMessage,
  }) {
    return ApplicationsState(
      status: status ?? this.status,
      applications: applications ?? this.applications,
      selectedFilter:
          clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      lastSubmitted: lastSubmitted ?? this.lastSubmitted,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        applications,
        selectedFilter,
        lastSubmitted,
        errorMessage,
      ];
}

class ApplicationsCubit extends Cubit<ApplicationsState> {
  ApplicationsCubit(this._repository, this._firebaseAuth)
      : super(const ApplicationsState()) {
    _activeUid = _firebaseAuth.currentUser?.uid;
    _authSubscription = _firebaseAuth.authStateChanges().listen(_onAuthChanged);
  }

  final ApplicationsRepository _repository;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _authSubscription;
  String? _activeUid;

  void _onAuthChanged(User? user) {
    final uid = user?.uid;
    if (uid == _activeUid) return;
    _activeUid = uid;
    if (uid == null) {
      emit(const ApplicationsState(status: ApplicationsStateStatus.loaded));
      return;
    }
    emit(const ApplicationsState(status: ApplicationsStateStatus.loading));
    unawaited(loadApplications());
  }

  Future<void> loadApplications() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      if (!isClosed) {
        emit(const ApplicationsState(status: ApplicationsStateStatus.loaded));
      }
      return;
    }
    _activeUid = uid;
    emit(
      state.copyWith(
        status: ApplicationsStateStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      final list = await _repository.getApplications();
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return;
      emit(
        state.copyWith(
          status: ApplicationsStateStatus.loaded,
          applications: list,
        ),
      );
    } catch (_) {
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return;
      emit(
        state.copyWith(
          status: ApplicationsStateStatus.error,
          errorMessage: 'تعذر تحميل طلبات التوظيف.',
        ),
      );
    }
  }

  void setFilter(ApplicationStatus? filter) {
    emit(
      state.copyWith(
        selectedFilter: filter,
        clearFilter: filter == null,
      ),
    );
  }

  Future<JobApplicationModel?> applyToJob(JobMatchModel job) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return null;
    emit(
      state.copyWith(
        status: ApplicationsStateStatus.submitting,
        errorMessage: null,
      ),
    );
    try {
      final created = await _repository.submitApplication(job);
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return null;
      final updated = [created, ...state.applications];
      emit(
        state.copyWith(
          status: ApplicationsStateStatus.submitted,
          applications: updated,
          lastSubmitted: created,
        ),
      );
      return created;
    } catch (_) {
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return null;
      emit(
        state.copyWith(
          status: ApplicationsStateStatus.error,
          errorMessage: 'تعذر إرسال طلب التوظيف. حاول مرة أخرى.',
        ),
      );
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await super.close();
  }
}
