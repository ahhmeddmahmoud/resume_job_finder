import 'package:equatable/equatable.dart';

class CareerPreferencesModel extends Equatable {
  const CareerPreferencesModel({
    required this.track,
    required this.experienceLevel,
    required this.experienceYears,
    required this.workType,
    required this.preferredCity,
  });

  final String track;
  final String experienceLevel;
  final int experienceYears;
  final String workType;
  final String preferredCity;

  Map<String, dynamic> toJson() {
    return {
      'track': track,
      'experienceLevel': experienceLevel,
      'experienceYears': experienceYears,
      'workType': workType,
      'preferredCity': preferredCity,
    };
  }

  factory CareerPreferencesModel.fromJson(Map<String, dynamic> json) {
    return CareerPreferencesModel(
      track: json['track'] as String? ?? 'Flutter',
      experienceLevel: json['experienceLevel'] as String? ?? 'Junior',
      experienceYears: json['experienceYears'] as int? ?? 1,
      workType: json['workType'] as String? ?? 'Full-time',
      preferredCity: json['preferredCity'] as String? ?? 'Cairo',
    );
  }

  @override
  List<Object?> get props => [
        track,
        experienceLevel,
        experienceYears,
        workType,
        preferredCity,
      ];
}
