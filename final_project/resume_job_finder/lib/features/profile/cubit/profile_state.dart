import 'package:equatable/equatable.dart';

import '../../resume_matching/models/resume_analysis_model.dart';

enum ProfileStatus { initial, loading, loaded, saving, saved, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.uid = '',
    this.fullName = '',
    this.email = '',
    this.targetRole = '',
    this.city = '',
    this.preferredSkills = const [],
    this.latestAnalysis,
    this.errorMessage,
  });

  final ProfileStatus status;
  final String uid;
  final String fullName;
  final String email;
  final String targetRole;
  final String city;
  final List<String> preferredSkills;
  final ResumeAnalysisModel? latestAnalysis;
  final String? errorMessage;

  bool get isLoading => status == ProfileStatus.loading;
  bool get isSaving => status == ProfileStatus.saving;

  ProfileState copyWith({
    ProfileStatus? status,
    String? uid,
    String? fullName,
    String? email,
    String? targetRole,
    String? city,
    List<String>? preferredSkills,
    ResumeAnalysisModel? latestAnalysis,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      targetRole: targetRole ?? this.targetRole,
      city: city ?? this.city,
      preferredSkills: preferredSkills ?? this.preferredSkills,
      latestAnalysis: latestAnalysis ?? this.latestAnalysis,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        uid,
        fullName,
        email,
        targetRole,
        city,
        preferredSkills,
        latestAnalysis,
        errorMessage,
      ];
}
