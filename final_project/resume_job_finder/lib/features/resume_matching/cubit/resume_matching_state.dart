import 'package:equatable/equatable.dart';

import '../models/resume_analysis_model.dart';

enum ResumeMatchingStatus { initial, loading, loaded, error }

class ResumeMatchingState extends Equatable {
  const ResumeMatchingState({
    this.status = ResumeMatchingStatus.initial,
    this.analysis,
    this.loadingMessage,
    this.progressPercent = 0,
    this.currentStepIndex = 0,
    this.errorMessage,
  });

  final ResumeMatchingStatus status;
  final ResumeAnalysisModel? analysis;
  final String? loadingMessage;
  final int progressPercent;
  final int currentStepIndex;
  final String? errorMessage;

  bool get isLoading => status == ResumeMatchingStatus.loading;

  ResumeMatchingState copyWith({
    ResumeMatchingStatus? status,
    ResumeAnalysisModel? analysis,
    bool clearAnalysis = false,
    String? loadingMessage,
    int? progressPercent,
    int? currentStepIndex,
    String? errorMessage,
  }) {
    return ResumeMatchingState(
      status: status ?? this.status,
      analysis: clearAnalysis ? null : (analysis ?? this.analysis),
      loadingMessage: loadingMessage,
      progressPercent: progressPercent ?? this.progressPercent,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        analysis,
        loadingMessage,
        progressPercent,
        currentStepIndex,
        errorMessage,
      ];
}
