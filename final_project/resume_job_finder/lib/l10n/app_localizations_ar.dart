// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مطابق السيرة والوظائف';

  @override
  String get splashTitleLine1 => 'Automated Resume Matching';

  @override
  String get splashTitleLine2 => '& Job Finder App';

  @override
  String get splashSubtitle => 'مساعدك الذكي لتحليل سيرتك والبحث عن الوظائف';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabJobs => 'الوظائف';

  @override
  String get tabSaved => 'المحفوظة';

  @override
  String get tabApplications => 'طلباتي';

  @override
  String get tabProfile => 'حسابي';

  @override
  String matchPercent(int percent) {
    return 'توافق $percent%';
  }

  @override
  String skillsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهارة',
      few: '$count مهارات',
      two: 'مهارتان',
      one: 'مهارة واحدة',
      zero: 'بدون مهارات',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get appearanceSection => 'المظهر';

  @override
  String get displayMode => 'وضع العرض';

  @override
  String get lightMode => 'فاتح';

  @override
  String get darkMode => 'داكن';

  @override
  String get languageSection => 'اللغة';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get signOut => 'تسجيل الخروج';
}
