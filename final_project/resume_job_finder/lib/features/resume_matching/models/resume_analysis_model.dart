import 'package:equatable/equatable.dart';

class JobMatchModel extends Equatable {
  const JobMatchModel({
    this.id,
    required this.title,
    required this.companyType,
    required this.location,
    required this.workType,
    required this.matchPercentage,
    required this.matchReason,
    this.missingSkills = const [],
    this.matchedSkills = const [],
    this.logoUrl,
    this.description,
    this.applyUrl,
    this.isRemote = false,
    this.isRealJob = false,
  });

  final String? id;
  final String title;
  final String companyType;
  final String location;
  final String workType;
  final int matchPercentage;
  final String matchReason;
  final List<String> missingSkills;
  final List<String> matchedSkills;
  final String? logoUrl;
  final String? description;
  final String? applyUrl;
  final bool isRemote;
  final bool isRealJob;

  factory JobMatchModel.fromJson(Map<String, dynamic> json) {
    final rawPercentage = json['matchPercentage'];
    final parsedPercentage = rawPercentage is num
        ? rawPercentage.round().clamp(0, 100)
        : int.tryParse(rawPercentage?.toString() ?? '')?.clamp(0, 100) ?? 0;

    return JobMatchModel(
      id: json['id'] as String?,
      title: (json['title'] as String?)?.trim() ?? '',
      companyType: (json['companyType'] as String?)?.trim() ?? '',
      location: (json['location'] as String?)?.trim() ?? '',
      workType: (json['workType'] as String?)?.trim() ?? '',
      matchPercentage: parsedPercentage,
      matchReason: (json['matchReason'] as String?)?.trim() ?? '',
      missingSkills: _parseStringList(json['missingSkills']),
      matchedSkills: _parseStringList(json['matchedSkills']),
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      applyUrl: json['applyUrl'] as String?,
      isRemote: (json['isRemote'] as bool?) ?? false,
      isRealJob: (json['isRealJob'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'companyType': companyType,
      'location': location,
      'workType': workType,
      'matchPercentage': matchPercentage,
      'matchReason': matchReason,
      'missingSkills': missingSkills,
      if (matchedSkills.isNotEmpty) 'matchedSkills': matchedSkills,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (description != null) 'description': description,
      if (applyUrl != null) 'applyUrl': applyUrl,
      if (isRemote) 'isRemote': isRemote,
      if (isRealJob) 'isRealJob': isRealJob,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        companyType,
        location,
        workType,
        matchPercentage,
        matchReason,
        missingSkills,
        matchedSkills,
        logoUrl,
        description,
        applyUrl,
        isRemote,
        isRealJob,
      ];
}

class ResumeAnalysisModel extends Equatable {
  const ResumeAnalysisModel({
    required this.fileName,
    required this.bestJobTitle,
    required this.experienceYears,
    required this.matchPercentage,
    required this.summary,
    required this.skills,
    required this.matchedSkills,
    required this.strengths,
    required this.missingSkills,
    required this.recommendedJobs,
    this.isLocalFallback = false,
    this.usedModel,
    this.analyzedAt,
  });

  final String fileName;
  final String bestJobTitle;
  final int experienceYears;
  final int matchPercentage;
  final String summary;
  final List<String> skills;
  final List<String> matchedSkills;
  final List<String> strengths;
  final List<String> missingSkills;
  final List<JobMatchModel> recommendedJobs;
  final bool isLocalFallback;
  final String? usedModel;
  final DateTime? analyzedAt;

  List<String> get skillGaps => missingSkills;
  List<JobMatchModel> get matchedJobs => recommendedJobs;

  factory ResumeAnalysisModel.fromJson(
    Map<String, dynamic> json, {
    String? fileName,
  }) {
    final rawYears = json['experienceYears'];
    final parsedYears = rawYears is num
        ? rawYears.round().clamp(0, 50)
        : int.tryParse(rawYears?.toString() ?? '')?.clamp(0, 50) ?? 0;

    final rawJobs = json['recommendedJobs'] ?? json['matchedJobs'];
    final parsedJobs = rawJobs is List
        ? rawJobs
            .whereType<Map>()
            .map((e) => JobMatchModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <JobMatchModel>[];

    final rawOverall = json['matchPercentage'];
    var parsedOverall = rawOverall is num
        ? rawOverall.round().clamp(0, 100)
        : int.tryParse(rawOverall?.toString() ?? '')?.clamp(0, 100) ?? 0;
    if (parsedOverall == 0 && parsedJobs.isNotEmpty) {
      parsedOverall = parsedJobs.first.matchPercentage;
    }

    final parsedSkills = _parseStringList(json['skills']);
    final parsedMatched = _parseStringList(json['matchedSkills']);
    final parsedMissing =
        _parseStringList(json['missingSkills'] ?? json['skillGaps']);

    final rawAnalyzedAt = json['analyzedAt'];
    DateTime? parsedDate;
    if (rawAnalyzedAt is String) {
      parsedDate = DateTime.tryParse(rawAnalyzedAt);
    }

    return ResumeAnalysisModel(
      fileName: fileName ?? (json['fileName'] as String?) ?? 'resume.pdf',
      bestJobTitle: (json['bestJobTitle'] as String?)?.trim() ?? '',
      experienceYears: parsedYears,
      matchPercentage: parsedOverall,
      summary: (json['summary'] as String?)?.trim() ?? '',
      skills: parsedSkills,
      matchedSkills: parsedMatched.isNotEmpty ? parsedMatched : parsedSkills,
      strengths: _parseStringList(json['strengths']),
      missingSkills: parsedMissing,
      recommendedJobs: parsedJobs,
      isLocalFallback: (json['isLocalFallback'] as bool?) ?? false,
      usedModel: json['usedModel'] as String?,
      analyzedAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'bestJobTitle': bestJobTitle,
      'experienceYears': experienceYears,
      'matchPercentage': matchPercentage,
      'summary': summary,
      'skills': skills,
      'matchedSkills': matchedSkills,
      'strengths': strengths,
      'missingSkills': missingSkills,
      'recommendedJobs': recommendedJobs.map((j) => j.toJson()).toList(),
      'isLocalFallback': isLocalFallback,
      if (usedModel != null) 'usedModel': usedModel,
      'analyzedAt': (analyzedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        fileName,
        bestJobTitle,
        experienceYears,
        matchPercentage,
        summary,
        skills,
        matchedSkills,
        strengths,
        missingSkills,
        recommendedJobs,
        isLocalFallback,
        usedModel,
        analyzedAt,
      ];
}

List<String> _parseStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((e) => e.toString().trim())
      .where((e) => e.isNotEmpty)
      .toList();
}
