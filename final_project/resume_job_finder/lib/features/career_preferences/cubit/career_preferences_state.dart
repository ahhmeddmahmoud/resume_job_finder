import 'package:equatable/equatable.dart';

enum CareerPreferencesStatus { initial, loading, saved, error }

class CareerPreferencesState extends Equatable {
  const CareerPreferencesState({
    this.track = 'Flutter',
    this.experienceLevel = 'مبتدئ',
    this.experienceYears = 1,
    this.workType = 'عن بعد',
    this.preferredCity = 'القاهرة',
    this.status = CareerPreferencesStatus.initial,
    this.errorMessage,
  });

  final String track;
  final String experienceLevel;
  final int experienceYears;
  final String workType;
  final String preferredCity;
  final CareerPreferencesStatus status;
  final String? errorMessage;

  bool get isLoading => status == CareerPreferencesStatus.loading;

  CareerPreferencesState copyWith({
    String? track,
    String? experienceLevel,
    int? experienceYears,
    String? workType,
    String? preferredCity,
    CareerPreferencesStatus? status,
    String? errorMessage,
  }) {
    return CareerPreferencesState(
      track: track ?? this.track,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      experienceYears: experienceYears ?? this.experienceYears,
      workType: workType ?? this.workType,
      preferredCity: preferredCity ?? this.preferredCity,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        track,
        experienceLevel,
        experienceYears,
        workType,
        preferredCity,
        status,
        errorMessage,
      ];
}
