import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only storage for user profile photos (`profile_<uid>.jpg`).
class ProfilePhotoLocalDataSource {
  ProfilePhotoLocalDataSource(
    this._prefs, {
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  final SharedPreferences _prefs;
  final ImagePicker _picker;

  String _prefsKey(String uid) => 'profile_photo_path_$uid';

  Future<String?> getPhotoPath(String uid) async {
    if (uid.isEmpty) return null;
    final path = _prefs.getString(_prefsKey(uid));
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) {
      await _prefs.remove(_prefsKey(uid));
      return null;
    }
    return path;
  }

  /// Picks an image, copies it to app documents as `profile_<uid>.jpg`,
  /// evicts any cached image, and returns the saved path (or `null` if cancelled).
  Future<String?> pickAndSavePhoto({
    required String uid,
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return null;

    final docsDir = await getApplicationDocumentsDirectory();
    final targetPath =
        '${docsDir.path}${Platform.pathSeparator}profile_$uid.jpg';
    final targetFile = File(targetPath);

    // Delete old file if present and evict from image cache.
    final oldPath = _prefs.getString(_prefsKey(uid));
    if (oldPath != null && oldPath.isNotEmpty) {
      await _evictPath(oldPath);
      final oldFile = File(oldPath);
      if (oldPath != targetPath && await oldFile.exists()) {
        await oldFile.delete();
      }
    }
    if (await targetFile.exists()) {
      await _evictPath(targetPath);
      await targetFile.delete();
    }

    await File(picked.path).copy(targetPath);
    await _evictPath(targetPath);
    await _prefs.setString(_prefsKey(uid), targetPath);
    return targetPath;
  }

  Future<void> removePhoto(String uid) async {
    if (uid.isEmpty) return;
    final existingPath = _prefs.getString(_prefsKey(uid));
    if (existingPath != null && existingPath.isNotEmpty) {
      await _evictPath(existingPath);
      final file = File(existingPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _prefs.remove(_prefsKey(uid));
  }

  Future<void> _evictPath(String path) async {
    try {
      await FileImage(File(path)).evict();
    } catch (_) {
      // Ignore cache eviction errors.
    }
  }
}
