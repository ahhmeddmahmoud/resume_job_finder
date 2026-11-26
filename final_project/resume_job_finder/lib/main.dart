import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection_container.dart';
import 'core/routing/app_router.dart';
import 'core/settings/app_settings_cubit.dart';
import 'core/settings/app_settings_state.dart';
import 'core/theme/app_theme.dart';
import 'features/applications/cubit/applications_cubit.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/jobs/cubit/saved_jobs_cubit.dart';
import 'features/profile_photo/cubit/profile_photo_cubit.dart';
import 'features/profile_photo/data/profile_photo_local_data_source.dart';
import 'features/resume_matching/cubit/resume_matching_cubit.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initDependencies();
  runApp(const ResumeJobFinderApp());
}

class ResumeJobFinderApp extends StatelessWidget {
  const ResumeJobFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppSettingsCubit>.value(value: sl<AppSettingsCubit>()),
        BlocProvider<AuthCubit>.value(value: sl<AuthCubit>()),
        BlocProvider<ResumeMatchingCubit>.value(
          value: sl<ResumeMatchingCubit>(),
        ),
        BlocProvider<SavedJobsCubit>.value(value: sl<SavedJobsCubit>()),
        BlocProvider<ApplicationsCubit>.value(value: sl<ApplicationsCubit>()),
        BlocProvider<ProfilePhotoCubit>(
          create: (_) => ProfilePhotoCubit(
            ProfilePhotoLocalDataSource(sl<SharedPreferences>()),
          ),
        ),
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Resume & Job Finder',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            themeAnimationDuration: const Duration(milliseconds: 260),
            themeAnimationCurve: Curves.easeInOutCubic,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
