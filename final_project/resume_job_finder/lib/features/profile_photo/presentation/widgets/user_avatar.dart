import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../cubit/profile_photo_cubit.dart';

/// Reusable circular user avatar that renders a local profile photo with
/// [ClipOval] + `cacheWidth`, falling back to user's initial or person icon.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.photoPath,
    this.displayName = '',
    this.size = 44,
    this.cacheVersion = 0,
    this.onTap,
  });

  final String? photoPath;
  final String displayName;
  final double size;
  final int cacheVersion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);
    final initial = displayName.trim().isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : '';

    final Widget content;
    if (photoPath != null && photoPath!.isNotEmpty) {
      final cachePx = (size * MediaQuery.devicePixelRatioOf(context)).round();
      content = ClipOval(
        child: Image.file(
          File(photoPath!),
          key: ValueKey('$photoPath#$cacheVersion'),
          width: size,
          height: size,
          cacheWidth: cachePx > 0 ? cachePx : 128,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackAvatar(
            size: size,
            initial: initial,
            bgColor: themeColors.chipBackground,
            fgColor: themeColors.primary,
          ),
        ),
      );
    } else {
      content = _FallbackAvatar(
        size: size,
        initial: initial,
        bgColor: themeColors.chipBackground,
        fgColor: themeColors.primary,
      );
    }

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Center(child: content),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({
    required this.size,
    required this.initial,
    required this.bgColor,
    required this.fgColor,
  });

  final double size;
  final String initial;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: initial.isNotEmpty
            ? Text(
                initial,
                style: TextStyle(
                  color: fgColor,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.4,
                ),
              )
            : Icon(
                Icons.person_outline_rounded,
                size: size * 0.5,
                color: fgColor,
              ),
      ),
    );
  }
}

/// Shows Camera / Gallery / Remove Photo bottom sheet for updating local avatar.
Future<void> showProfilePhotoOptionsSheet(
  BuildContext context, {
  required String uid,
  required bool hasPhoto,
}) async {
  final strings = AppStrings.of(context);
  final cubit = context.read<ProfilePhotoCubit>();

  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
                title: Text(strings.tr('التقاط صورة بالكاميرا', 'Take Photo')),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  cubit.pickPhoto(uid: uid, source: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  strings.tr('اختيار من المعرض', 'Choose from Gallery'),
                ),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  cubit.pickPhoto(uid: uid, source: ImageSource.gallery);
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                  title: Text(
                    strings.tr('إزالة الصورة', 'Remove Photo'),
                    style: const TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    cubit.removePhoto(uid);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}
