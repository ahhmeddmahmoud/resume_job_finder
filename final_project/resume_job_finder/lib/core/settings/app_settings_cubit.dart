import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../storage/local_storage_service.dart';
import 'app_settings_state.dart';

/// Manages app-wide locale (AR/EN) and theme mode (Light/Dark) with persistence.
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit(this._storage)
      : super(
          AppSettingsState(
            locale: Locale(_storage.localeCode),
            themeMode:
                _storage.themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light,
          ),
        );

  final LocalStorageService _storage;
  Future<void> _pendingPersistence = Future<void>.value();

  Future<void> _persist(Future<bool> Function() write) {
    final next = _pendingPersistence.then((_) async {
      await write();
    });
    _pendingPersistence = next.catchError((Object _) {});
    return next;
  }

  Future<void> toggleLanguage() async {
    final nextCode = state.isArabic ? 'en' : 'ar';
    emit(state.copyWith(locale: Locale(nextCode)));
    await _persist(() => _storage.setLocaleCode(nextCode));
  }

  Future<void> toggleTheme() async {
    final nextTheme = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    emit(state.copyWith(themeMode: nextTheme));
    await _persist(
      () =>
          _storage.setThemeMode(nextTheme == ThemeMode.dark ? 'dark' : 'light'),
    );
  }
}
