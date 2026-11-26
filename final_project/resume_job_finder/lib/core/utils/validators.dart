import 'package:material_ui/material_ui.dart';

/// Form field validators with localized Arabic/English messages.
class AppValidators {
  AppValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  static String? fullName(BuildContext context, String? value) {
    final text = value?.trim() ?? '';
    final isAr = _isArabic(context);
    if (text.isEmpty) {
      return isAr ? 'الاسم الكامل مطلوب' : 'Full name is required';
    }
    if (text.length < 3) {
      return isAr
          ? 'الاسم يجب أن يكون 3 أحرف على الأقل'
          : 'Name must be at least 3 characters';
    }
    return null;
  }

  static String? email(BuildContext context, String? value) {
    final text = value?.trim() ?? '';
    final isAr = _isArabic(context);
    if (text.isEmpty) {
      return isAr ? 'البريد الإلكتروني مطلوب' : 'Email address is required';
    }
    if (!_emailRegex.hasMatch(text)) {
      return isAr ? 'صيغة البريد الإلكتروني غير صحيحة' : 'Invalid email format';
    }
    return null;
  }

  static String? password(BuildContext context, String? value) {
    final text = value ?? '';
    final isAr = _isArabic(context);
    if (text.isEmpty) {
      return isAr ? 'كلمة المرور مطلوبة' : 'Password is required';
    }
    if (text.length < 6) {
      return isAr
          ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
          : 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(
    BuildContext context,
    String? value,
    String originalPassword,
  ) {
    final baseError = password(context, value);
    if (baseError != null) return baseError;
    if (value != originalPassword) {
      return _isArabic(context)
          ? 'كلمتا المرور غير متطابقتين'
          : 'Passwords do not match';
    }
    return null;
  }
}
