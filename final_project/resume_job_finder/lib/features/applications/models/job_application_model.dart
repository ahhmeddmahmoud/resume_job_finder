import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  applied,
  submitted,
  underReview,
  interview,
  accepted,
  rejected;

  String get arabicLabel => switch (this) {
        ApplicationStatus.applied ||
        ApplicationStatus.submitted =>
          'تم التقديم',
        ApplicationStatus.underReview => 'قيد المراجعة',
        ApplicationStatus.interview => 'مقابلة',
        ApplicationStatus.accepted => 'مقبول',
        ApplicationStatus.rejected => 'مرفوض',
      };

  String localizedLabel({required bool isArabic}) {
    if (isArabic) return arabicLabel;
    return switch (this) {
      ApplicationStatus.applied || ApplicationStatus.submitted => 'Applied',
      ApplicationStatus.underReview => 'Under Review',
      ApplicationStatus.interview => 'Interview',
      ApplicationStatus.accepted => 'Accepted',
      ApplicationStatus.rejected => 'Rejected',
    };
  }

  static ApplicationStatus fromString(String? value) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ApplicationStatus.submitted,
    );
  }
}

class JobApplicationModel extends Equatable {
  const JobApplicationModel({
    required this.id,
    required this.jobTitle,
    required this.companyType,
    required this.location,
    required this.workType,
    required this.matchPercentage,
    required this.status,
    required this.appliedAt,
    this.applyUrl,
  });

  final String id;
  final String jobTitle;
  final String companyType;
  final String location;
  final String workType;
  final int matchPercentage;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final String? applyUrl;

  factory JobApplicationModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    final rawDate = map['appliedAt'];
    DateTime parsedDate = DateTime.now();
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return JobApplicationModel(
      id: id,
      jobTitle: (map['jobTitle'] as String?) ?? (map['title'] as String?) ?? '',
      companyType:
          (map['companyType'] as String?) ?? (map['company'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      workType: (map['workType'] as String?) ?? '',
      matchPercentage: (map['matchPercentage'] as num?)?.round() ?? 0,
      status: ApplicationStatus.fromString(map['status'] as String?),
      appliedAt: parsedDate,
      applyUrl: map['applyUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobTitle': jobTitle,
      'companyType': companyType,
      'location': location,
      'workType': workType,
      'matchPercentage': matchPercentage,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      if (applyUrl != null) 'applyUrl': applyUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        jobTitle,
        companyType,
        location,
        workType,
        matchPercentage,
        status,
        appliedAt,
        applyUrl,
      ];
}
