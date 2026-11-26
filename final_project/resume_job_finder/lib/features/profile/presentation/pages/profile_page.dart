import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_tile_card.dart';
import '../../../applications/cubit/applications_cubit.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../profile_photo/cubit/profile_photo_cubit.dart';
import '../../../profile_photo/presentation/widgets/user_avatar.dart';
import '../../../resume_matching/cubit/resume_matching_cubit.dart';
import '../../cubit/profile_cubit.dart';
import '../../cubit/profile_state.dart';

/// 19 — Profile screen connected to `users/{uid}`, local [UserAvatar], and live stats.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  String _loadedUid = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.watch<AuthCubit>().state.user?.uid ?? '';
    if (uid.isNotEmpty && uid != _loadedUid) {
      _loadedUid = uid;
      context.read<ProfilePhotoCubit>().loadPhoto(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) {
            if (authState.status == AuthStatus.loggedOut) {
              context.go(AppRoutes.login);
            }
          },
        ),
        BlocListener<ProfilePhotoCubit, ProfilePhotoState>(
          listenWhen: (prev, curr) =>
              curr.errorType != ProfilePhotoErrorType.none &&
              curr.errorType != prev.errorType,
          listener: (context, photoState) {
            final msg = switch (photoState.errorType) {
              ProfilePhotoErrorType.permissionDenied => strings.tr(
                  'تم رفض إذن الكاميرا أو المعرض. يرجى تفعيله من إعدادات الجهاز.',
                  'Camera or gallery permission denied. Please enable it in device settings.',
                ),
              ProfilePhotoErrorType.generic => strings.tr(
                  'تعذر تحديث الصورة الشخصية. حاول مرة أخرى.',
                  'Could not update profile photo. Please try again.',
                ),
              ProfilePhotoErrorType.none => '',
            };
            if (msg.isNotEmpty) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(msg)));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.tr('الملف الشخصي', 'Profile')),
        ),
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final uid = state.uid.isNotEmpty
                  ? state.uid
                  : (context.read<AuthCubit>().state.user?.uid ?? '');
              final cvAnalysis =
                  context.watch<ResumeMatchingCubit>().state.analysis ??
                      state.latestAnalysis;
              final appsCount =
                  context.watch<ApplicationsCubit>().state.applications.length;
              final cvCount = cvAnalysis != null ? 1 : 0;
              final matchPct = cvAnalysis?.matchPercentage ?? 0;
              final cardColor =
                  theme.cardTheme.color ?? theme.colorScheme.surface;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            BlocBuilder<ProfilePhotoCubit, ProfilePhotoState>(
                              builder: (context, photoState) {
                                return InkWell(
                                  borderRadius: BorderRadius.circular(52),
                                  onTap: photoState.isSaving || uid.isEmpty
                                      ? null
                                      : () => showProfilePhotoOptionsSheet(
                                            context,
                                            uid: uid,
                                            hasPhoto: photoState.hasPhoto,
                                          ),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        UserAvatar(
                                          photoPath: photoState.photoPath,
                                          displayName: state.fullName,
                                          size: 96,
                                          cacheVersion: photoState.version,
                                        ),
                                        if (photoState.isSaving)
                                          Container(
                                            width: 96,
                                            height: 96,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black
                                                  .withValues(alpha: 0.45),
                                            ),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        PositionedDirectional(
                                          bottom: 0,
                                          end: 0,
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: cardColor,
                                                width: 2.5,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.fullName.isNotEmpty
                                  ? state.fullName
                                  : strings.tr('مستخدم DEPI', 'DEPI User'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.targetRole.isNotEmpty
                                  ? state.targetRole
                                  : state.email,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.68),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileStatCard(
                            value: '$cvCount',
                            label: strings.tr('السيرة', 'Resume'),
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ProfileStatCard(
                            value: cvAnalysis != null ? '$matchPct%' : '--',
                            label: strings.tr('توافق', 'Match'),
                            color: AppColors.matchColor(matchPct),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ProfileStatCard(
                            value: '$appsCount',
                            label: strings.tr('طلبات', 'Applied'),
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      strings.tr('إدارة الحساب', 'Account Management'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SectionTileCard(
                      icon: Icons.edit_outlined,
                      title: strings.tr('تعديل الملف الشخصي', 'Edit Profile'),
                      subtitle: strings.tr(
                        'الاسم، المسمى الوظيفي، المدينة',
                        'Name, job title, city',
                      ),
                      onTap: () async {
                        await context.push(AppRoutes.editProfile);
                        if (context.mounted) {
                          context.read<ProfileCubit>().loadProfile();
                        }
                      },
                    ),
                    SectionTileCard(
                      icon: Icons.description_outlined,
                      title: strings.tr('السيرة الذاتية', 'My Resume'),
                      subtitle: cvAnalysis != null
                          ? cvAnalysis.fileName
                          : strings.tr(
                              'إدارة أو رفع ملف PDF',
                              'Manage or upload a PDF file',
                            ),
                      onTap: () => context.push(AppRoutes.cvManagement),
                    ),
                    SectionTileCard(
                      icon: Icons.bookmark_border_rounded,
                      title: strings.tr('الوظائف المحفوظة', 'Saved Jobs'),
                      subtitle: strings.tr(
                        'عرض الوظائف التي قمت بحفظها',
                        'View jobs you saved for later',
                      ),
                      onTap: () => context.go(AppRoutes.savedJobs),
                    ),
                    SectionTileCard(
                      icon: Icons.settings_outlined,
                      title: strings.tr('الإعدادات', 'Settings'),
                      subtitle: strings.tr(
                        'المظهر، اللغة، الخصوصية، الخروج',
                        'Theme, language, privacy, sign out',
                      ),
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
