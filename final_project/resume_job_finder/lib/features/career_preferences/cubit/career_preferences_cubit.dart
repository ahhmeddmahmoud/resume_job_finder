import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../auth/data/auth_repository.dart';
import '../models/career_preferences_model.dart';
import 'career_preferences_state.dart';

/// Manages user's career preferences selection and Firestore + local persistence.
class CareerPreferencesCubit extends Cubit<CareerPreferencesState> {
  CareerPreferencesCubit(
    this._storage, {
    AuthRepository? authRepository,
  })  : _authRepository = authRepository,
        super(const CareerPreferencesState()) {
    loadSavedPreferences();
  }

  final LocalStorageService _storage;
  final AuthRepository? _authRepository;

  static const List<String> tracks = [
    'Flutter',
    'Frontend',
    'Backend',
    'Full-stack',
    'Data / AI',
    'Mobile',
  ];

  static const List<String> experienceLevels = [
    'مبتدئ',
    'متوسط',
    'متقدم',
  ];

  static const List<String> workTypes = [
    'عن بعد',
    'في المكتب',
    'هجين',
  ];

  static const List<String> cities = [
    'القاهرة',
    'الإسكندرية',
    'الجيزة',
    'المنصورة',
    'الرياض',
    'دبي',
  ];

  void loadSavedPreferences() {
    final json = _storage.getCareerPreferencesJson();
    if (json == null) return;
    final model = CareerPreferencesModel.fromJson(json);
    emit(
      state.copyWith(
        track: model.track,
        experienceLevel: model.experienceLevel,
        experienceYears: model.experienceYears,
        workType: model.workType,
        preferredCity: model.preferredCity,
        status: CareerPreferencesStatus.initial,
      ),
    );
  }

  void selectTrack(String track) {
    emit(state.copyWith(track: track, status: CareerPreferencesStatus.initial));
  }

  void selectExperienceLevel(String level) {
    emit(
      state.copyWith(
        experienceLevel: level,
        status: CareerPreferencesStatus.initial,
      ),
    );
  }

  void incrementYears() {
    if (state.experienceYears >= 25) return;
    emit(
      state.copyWith(
        experienceYears: state.experienceYears + 1,
        status: CareerPreferencesStatus.initial,
      ),
    );
  }

  void decrementYears() {
    if (state.experienceYears <= 0) return;
    emit(
      state.copyWith(
        experienceYears: state.experienceYears - 1,
        status: CareerPreferencesStatus.initial,
      ),
    );
  }

  void selectWorkType(String workType) {
    emit(
      state.copyWith(
        workType: workType,
        status: CareerPreferencesStatus.initial,
      ),
    );
  }

  void selectCity(String city) {
    emit(
      state.copyWith(
        preferredCity: city,
        status: CareerPreferencesStatus.initial,
      ),
    );
  }

  Future<void> savePreferences({required String validationError}) async {
    if (state.track.isEmpty ||
        state.experienceLevel.isEmpty ||
        state.workType.isEmpty ||
        state.preferredCity.isEmpty) {
      emit(
        state.copyWith(
          status: CareerPreferencesStatus.error,
          errorMessage: validationError,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: CareerPreferencesStatus.loading,
        errorMessage: null,
      ),
    );

    final model = CareerPreferencesModel(
      track: state.track,
      experienceLevel: state.experienceLevel,
      experienceYears: state.experienceYears,
      workType: state.workType,
      preferredCity: state.preferredCity,
    );

    try {
      final currentUser = _authRepository?.currentUser;
      if (currentUser != null) {
        await _authRepository!.saveCareerPreferences(
          uid: currentUser.uid,
          preferences: model,
        );
        if (_authRepository.currentUser?.uid != currentUser.uid) return;
      }

      final ok = await _storage.saveCareerPreferencesJson(model.toJson());
      if (isClosed) return;

      if (!ok) {
        emit(
          state.copyWith(
            status: CareerPreferencesStatus.error,
            errorMessage: validationError,
          ),
        );
        return;
      }

      emit(state.copyWith(status: CareerPreferencesStatus.saved));
    } on FirebaseException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CareerPreferencesStatus.error,
          errorMessage: e.message ??
              'تعذر حفظ التفضيلات في السحابة، تحقق من اتصال الإنترنت.',
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CareerPreferencesStatus.error,
          errorMessage: 'حدث خطأ أثناء حفظ التفضيلات، حاول مرة أخرى.',
        ),
      );
    }
  }
}
