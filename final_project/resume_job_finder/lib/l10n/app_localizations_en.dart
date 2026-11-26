// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Resume & Job Finder';

  @override
  String get splashTitleLine1 => 'Automated Resume Matching';

  @override
  String get splashTitleLine2 => '& Job Finder App';

  @override
  String get splashSubtitle =>
      'Your smart assistant to analyze your CV & find jobs';

  @override
  String get tabHome => 'Home';

  @override
  String get tabJobs => 'Jobs';

  @override
  String get tabSaved => 'Saved';

  @override
  String get tabApplications => 'Applications';

  @override
  String get tabProfile => 'Profile';

  @override
  String matchPercent(int percent) {
    return '$percent% Match';
  }

  @override
  String skillsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skills',
      one: '1 skill',
      zero: 'No skills',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get displayMode => 'Display Mode';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get languageSection => 'Language';

  @override
  String get appLanguage => 'App Language';

  @override
  String get signOut => 'Sign Out';
}
