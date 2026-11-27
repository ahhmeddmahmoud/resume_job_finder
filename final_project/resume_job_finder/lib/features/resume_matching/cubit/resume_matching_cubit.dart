import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../jobs/data/jsearch_jobs_repository.dart';
import '../data/resume_matching_repository.dart';
import '../models/resume_analysis_model.dart';
import '../services/gemini_resume_service.dart';
import '../services/pdf_text_extractor_service.dart';
import 'resume_matching_state.dart';

class ResumeMatchingCubit extends Cubit<ResumeMatchingState> {
  ResumeMatchingCubit({
    required PdfTextExtractorService pdfExtractor,
    required GeminiResumeService geminiService,
    required ResumeMatchingRepository repository,
    required JSearchJobsRepository jobsRepository,
    required FirebaseAuth firebaseAuth,
  })  : _pdfExtractor = pdfExtractor,
        _geminiService = geminiService,
        _repository = repository,
        _jobsRepository = jobsRepository,
        _firebaseAuth = firebaseAuth,
        super(const ResumeMatchingState()) {
    _activeUid = _firebaseAuth.currentUser?.uid;
    _authSubscription = _firebaseAuth.authStateChanges().listen(_onAuthChanged);
  }

  final PdfTextExtractorService _pdfExtractor;
  final GeminiResumeService _geminiService;
  final ResumeMatchingRepository _repository;
  final JSearchJobsRepository _jobsRepository;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _authSubscription;
  String? _activeUid;

  PickedPdfResult? _lastPickedPdf;
  String? get selectedFileName => _lastPickedPdf?.fileName;

  void _onAuthChanged(User? user) {
    final uid = user?.uid;
    if (uid == _activeUid) return;
    _activeUid = uid;
    _lastPickedPdf = null;
    emit(const ResumeMatchingState());
    if (uid != null) unawaited(loadLatestAnalysis());
  }

  Future<void> loadLatestAnalysis() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      if (!isClosed) emit(const ResumeMatchingState());
      return;
    }
    try {
      final latest = await _repository.getLatestAnalysisResult();
      if (isClosed || _firebaseAuth.currentUser?.uid != uid || latest == null) {
        return;
      }
      emit(
        ResumeMatchingState(
          status: ResumeMatchingStatus.loaded,
          analysis: latest,
          progressPercent: 100,
          currentStepIndex: 3,
        ),
      );
    } catch (_) {
      // Ignore initial cache load errors.
    }
  }

  /// Picks a PDF, extracts text locally, and returns true if a valid file was picked.
  Future<bool> pickPdfFile() async {
    final uid = _firebaseAuth.currentUser?.uid;
    emit(
      state.copyWith(
        status: ResumeMatchingStatus.loading,
        loadingMessage: 'جارٍ قراءة ملف PDF محليًا...',
        progressPercent: 18,
        currentStepIndex: 0,
        errorMessage: null,
      ),
    );

    try {
      final picked = await _pdfExtractor.pickAndExtractPdfText();
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return false;

      if (picked == null) {
        emit(
          state.copyWith(
            status: state.analysis != null
                ? ResumeMatchingStatus.loaded
                : ResumeMatchingStatus.initial,
            loadingMessage: null,
            progressPercent: 0,
            currentStepIndex: 0,
          ),
        );
        return false;
      }

      _lastPickedPdf = picked;
      emit(
        state.copyWith(
          status: state.analysis != null
              ? ResumeMatchingStatus.loaded
              : ResumeMatchingStatus.initial,
          loadingMessage: null,
          progressPercent: 0,
          currentStepIndex: 0,
          errorMessage: null,
        ),
      );
      return true;
    } on FormatException catch (e) {
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return false;
      emit(
        state.copyWith(
          status: ResumeMatchingStatus.error,
          loadingMessage: null,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return false;
      emit(
        state.copyWith(
          status: ResumeMatchingStatus.error,
          loadingMessage: null,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
      return false;
    }
  }

  /// Re-fetches live jobs for the current analysis (pull-to-refresh).
  Future<void> refreshJobs() async {
    final current = state.analysis;
    if (current == null) return;
    try {
      final preferences = await _repository.getUserCareerPreferences();
      if (isClosed) return;
      final jobs = await _jobsRepository.fetchJobs(
        analysis: current,
        preferences: preferences,
        fallbackJobs: current.recommendedJobs,
      );
      if (isClosed) return;
      final updated = ResumeAnalysisModel(
        fileName: current.fileName,
        bestJobTitle: current.bestJobTitle,
        experienceYears: current.experienceYears,
        matchPercentage: current.matchPercentage,
        summary: current.summary,
        skills: current.skills,
        matchedSkills: current.matchedSkills,
        strengths: current.strengths,
        missingSkills: current.missingSkills,
        recommendedJobs: jobs,
        isLocalFallback: current.isLocalFallback,
        usedModel: current.usedModel,
        analyzedAt: current.analyzedAt,
      );
      emit(state.copyWith(analysis: updated));
      await _repository.saveAnalysisResult(updated);
    } catch (_) {
      // Keep the old jobs if the refresh fails.
    }
  }

  /// Runs the CV analysis, live job search, and persistence pipeline.
  Future<void> runAnalysisPipeline() async {
    final picked = _lastPickedPdf;
    if (picked == null) {
      final ok = await pickPdfFile();
      if (!ok || _lastPickedPdf == null) return;
    }

    final activePdf = _lastPickedPdf!;
    final uid = _firebaseAuth.currentUser?.uid;
    try {
      emit(
        state.copyWith(
          status: ResumeMatchingStatus.loading,
          loadingMessage: 'تجهيز نص السيرة الذاتية...',
          progressPercent: 24,
          currentStepIndex: 0,
          errorMessage: null,
        ),
      );

      final preferences = await _repository.getUserCareerPreferences();
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return;

      emit(
        state.copyWith(
          status: ResumeMatchingStatus.loading,
          loadingMessage:
              'تحليل المهارات والتخصص باستخدام Gemini أو المحلل المحلي...',
          progressPercent: 48,
          currentStepIndex: 1,
          errorMessage: null,
        ),
      );

      final analysis = await _geminiService.analyzeResume(
        fileName: activePdf.fileName,
        resumeText: activePdf.extractedText,
        preferences: preferences,
      );
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return;

      emit(
        state.copyWith(
          status: ResumeMatchingStatus.loading,
          loadingMessage: 'البحث عن وظائف مناسبة عبر JSearch...',
          progressPercent: 70,
          currentStepIndex: 2,
          errorMessage: null,
        ),
      );
      final jobs = await _jobsRepository.fetchJobs(
        analysis: analysis,
        preferences: preferences,
        fallbackJobs: analysis.recommendedJobs,
      );
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return;
      final enrichedAnalysis = ResumeAnalysisModel(
        fileName: analysis.fileName,
        bestJobTitle: analysis.bestJobTitle,
        experienceYears: analysis.experienceYears,
        matchPercentage: analysis.matchPercentage,
        summary: analysis.summary,
        skills: analysis.skills,
        matchedSkills: analysis.matchedSkills,
        strengths: analysis.strengths,
        missingSkills: analysis.missingSkills,
        recommendedJobs: jobs,
        isLocalFallback: analysis.isLocalFallback,
        usedModel: analysis.usedModel,
        analyzedAt: analysis.analyzedAt,
      );
      if (isClosed) return;

      emit(
        state.copyWith(
          status: ResumeMatchingStatus.loading,
          loadingMessage: 'حفظ النتائج في Cloud Firestore...',
          progressPercent: 92,
          currentStepIndex: 3,
          errorMessage: null,
        ),
      );

      await _repository.saveAnalysisResult(enrichedAnalysis);
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return;

      emit(
        ResumeMatchingState(
          status: ResumeMatchingStatus.loaded,
          analysis: enrichedAnalysis,
          progressPercent: 100,
          currentStepIndex: 3,
        ),
      );
    } catch (e) {
      if (isClosed || _firebaseAuth.currentUser?.uid != uid) return;
      emit(
        state.copyWith(
          status: ResumeMatchingStatus.error,
          loadingMessage: null,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> pickAndAnalyzeResume() async {
    final ok = await pickPdfFile();
    if (!ok) return;
    await runAnalysisPipeline();
  }

  Future<void> deleteCv() async {
    final uid = _firebaseAuth.currentUser?.uid;
    _lastPickedPdf = null;
    await _repository.clearAnalysisResult();
    if (isClosed || _firebaseAuth.currentUser?.uid != uid) return;
    emit(
      const ResumeMatchingState(
        status: ResumeMatchingStatus.initial,
        progressPercent: 0,
        currentStepIndex: 0,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await super.close();
  }
}
