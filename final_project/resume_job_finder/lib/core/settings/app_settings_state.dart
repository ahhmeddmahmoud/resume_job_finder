import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({
    required this.locale,
    required this.themeMode,
  });

  final Locale locale;
  final ThemeMode themeMode;

  bool get isArabic => locale.languageCode == 'ar';
  bool get isDarkMode => themeMode == ThemeMode.dark;

  AppSettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
  }) {
    return AppSettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [locale.languageCode, themeMode];
}
