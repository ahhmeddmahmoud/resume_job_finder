import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../data/profile_photo_local_data_source.dart';

enum ProfilePhotoErrorType { none, permissionDenied, generic }

class ProfilePhotoState extends Equatable {
  const ProfilePhotoState({
    this.photoPath,
    this.isSaving = false,
    this.errorType = ProfilePhotoErrorType.none,
    this.version = 0,
  });

  final String? photoPath;
  final bool isSaving;
  final ProfilePhotoErrorType errorType;
  final int version;

  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  ProfilePhotoState copyWith({
    String? photoPath,
    bool clearPhoto = false,
    bool? isSaving,
    ProfilePhotoErrorType? errorType,
    int? version,
  }) {
    return ProfilePhotoState(
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      isSaving: isSaving ?? this.isSaving,
      errorType: errorType ?? ProfilePhotoErrorType.none,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [photoPath, isSaving, errorType, version];
}

class ProfilePhotoCubit extends Cubit<ProfilePhotoState> {
  ProfilePhotoCubit(this._dataSource) : super(const ProfilePhotoState());

  final ProfilePhotoLocalDataSource _dataSource;

  Future<void> loadPhoto(String uid) async {
    if (uid.isEmpty) return;
    final path = await _dataSource.getPhotoPath(uid);
    if (isClosed) return;
    emit(
      state.copyWith(
        photoPath: path,
        clearPhoto: path == null,
        errorType: ProfilePhotoErrorType.none,
      ),
    );
  }

  Future<void> pickPhoto({
    required String uid,
    required ImageSource source,
  }) async {
    if (uid.isEmpty) return;
    emit(state.copyWith(isSaving: true, errorType: ProfilePhotoErrorType.none));
    try {
      final path = await _dataSource.pickAndSavePhoto(uid: uid, source: source);
      if (isClosed) return;
      if (path == null) {
        emit(state.copyWith(isSaving: false));
        return;
      }
      emit(
        state.copyWith(
          photoPath: path,
          isSaving: false,
          version: state.version + 1,
        ),
      );
    } on PlatformException catch (e) {
      if (isClosed) return;
      final isPermission = e.code.toLowerCase().contains('access') ||
          e.code.toLowerCase().contains('permission') ||
          e.code.toLowerCase().contains('denied');
      emit(
        state.copyWith(
          isSaving: false,
          errorType: isPermission
              ? ProfilePhotoErrorType.permissionDenied
              : ProfilePhotoErrorType.generic,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSaving: false,
          errorType: ProfilePhotoErrorType.generic,
        ),
      );
    }
  }

  Future<void> removePhoto(String uid) async {
    if (uid.isEmpty) return;
    emit(state.copyWith(isSaving: true, errorType: ProfilePhotoErrorType.none));
    try {
      await _dataSource.removePhoto(uid);
      if (isClosed) return;
      emit(
        state.copyWith(
          clearPhoto: true,
          isSaving: false,
          version: state.version + 1,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSaving: false,
          errorType: ProfilePhotoErrorType.generic,
        ),
      );
    }
  }
}
