import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../../../core/widgets/section_tile_card.dart';
import '../../../auth/cubit/auth_cubit.dart';

/// 23 — Privacy & Security screen.
class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  void _showPrivacyPolicy(BuildContext context) {
    final strings = AppStrings.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.tr('سياسة الخصوصية', 'Privacy Policy')),
        content: SingleChildScrollView(
          child: Text(
            strings.tr(
              'نحن نحترم خصوصيتك. تُستخدم بيانات السيرة الذاتية والتفضيلات المهنية '
                  'فقط لتحليل المهارات ومطابقة الوظائف المناسبة لك، ويتم تخزينها '
                  'بشكل آمن تحت حسابك في Cloud Firestore مع إمكانية حذفها في أي وقت.',
              'We respect your privacy. Your resume and career preferences are '
                  'used solely to extract skills and match relevant jobs, and are '
                  'stored securely under your Cloud Firestore account where you can delete them anytime.',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(strings.tr('حسنًا', 'OK')),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            strings.tr('حذف الحساب نهائيًا', 'Delete Account Permanently')),
        content: Text(
          strings.tr(
            'سيتم حذف بيانات حسابك وسيرتك الذاتية من Cloud Firestore. هل تريد المتابعة؟',
            'Your account and saved resume data will be permanently deleted from Cloud Firestore. Continue?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(strings.tr('إلغاء', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              strings.tr('حذف الحساب', 'Delete Account'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        await user.delete();
      }
      if (context.mounted) {
        await context.read<AuthCubit>().signOut();
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      final message = e.code == 'requires-recent-login'
          ? strings.tr(
              'يرجى تسجيل الخروج وإعادة تسجيل الدخول قبل حذف الحساب لأسباب أمنية.',
              'Please sign out and sign in again before deleting your account.',
            )
          : strings.tr(
              'تعذر حذف الحساب: ${e.message ?? e.code}',
              'Failed to delete account: ${e.message ?? e.code}',
            );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppHeaderBar(
        title: strings.tr('الخصوصية والأمان', 'Privacy & Security'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppColors.softBlue(context),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.tr(
                                'بياناتك تحت سيطرتك',
                                'Your Data Is Under Your Control',
                              ),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.softBlueFg(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.tr(
                                'تحكّم في بيانات حسابك وسيرتك الذاتية في أي وقت.',
                                'Manage your account and resume data anytime.',
                              ),
                              style: TextStyle(
                                color: AppColors.softBlueFg(context),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                strings.tr('أمان الحساب', 'Account Security'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              SectionTileCard(
                icon: Icons.lock_outline_rounded,
                title: strings.tr('تغيير كلمة المرور', 'Change Password'),
                subtitle: strings.tr(
                  'تحديث كلمة مرور الحساب',
                  'Update your account password',
                ),
                onTap: () => context.push(AppRoutes.resetPassword),
              ),
              SectionTileCard(
                icon: Icons.security_rounded,
                title: strings.tr('حماية الحساب', 'Account Protection'),
                subtitle: strings.tr(
                  'مفعل عبر Firebase Authentication',
                  'Protected via Firebase Authentication',
                ),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      strings.tr(
                        'حسابك محمي عبر Firebase Authentication.',
                        'Your account is secured via Firebase Authentication.',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                strings.tr('بياناتك الشخصية', 'Personal Data'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              SectionTileCard(
                icon: Icons.description_outlined,
                title: strings.tr('بيانات السيرة الذاتية', 'Resume Data'),
                subtitle: strings.tr(
                  'عرض أو حذف ملف السيرة المحفوظ',
                  'View or delete your saved resume',
                ),
                onTap: () => context.push(AppRoutes.cvManagement),
              ),
              SectionTileCard(
                icon: Icons.privacy_tip_outlined,
                title: strings.tr('سياسة الخصوصية', 'Privacy Policy'),
                subtitle: strings.tr(
                  'اطلع على سياسة استخدام البيانات',
                  'Read how your data is used',
                ),
                onTap: () => _showPrivacyPolicy(context),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _confirmDeleteAccount(context),
                child: Text(
                  strings.tr('حذف الحساب', 'Delete Account'),
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
