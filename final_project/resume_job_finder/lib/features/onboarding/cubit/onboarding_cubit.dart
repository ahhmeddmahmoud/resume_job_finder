import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/local_storage_service.dart';
import 'onboarding_state.dart';

/// Handles onboarding page index and completion persistence.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._storage) : super(const OnboardingState());

  final LocalStorageService _storage;

  void onPageChanged(int index) {
    emit(state.copyWith(currentPage: index));
  }

  Future<void> completeOnboarding() async {
    emit(state.copyWith(isSaving: true));
    await _storage.setOnboardingCompleted(true);
    if (isClosed) return;
    emit(state.copyWith(isSaving: false, isCompleted: true));
  }
}
