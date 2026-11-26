import 'package:equatable/equatable.dart';

enum SplashDestination { none, onboarding, login, careerPreferences, home }

class SplashState extends Equatable {
  const SplashState({
    this.isChecking = true,
    this.destination = SplashDestination.none,
  });

  final bool isChecking;
  final SplashDestination destination;

  SplashState copyWith({
    bool? isChecking,
    SplashDestination? destination,
  }) {
    return SplashState(
      isChecking: isChecking ?? this.isChecking,
      destination: destination ?? this.destination,
    );
  }

  @override
  List<Object?> get props => [isChecking, destination];
}
