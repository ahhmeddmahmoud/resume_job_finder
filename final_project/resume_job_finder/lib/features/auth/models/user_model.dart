import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../career_preferences/models/career_preferences_model.dart';

class UserModel extends Equatable {
  const UserModel({
    this.uid = '',
    required this.name,
    required this.email,
    this.preferencesCompleted = false,
    this.createdAt,
    this.careerPreferences,
  });

  final String uid;
  final String name;
  final String email;
  final bool preferencesCompleted;
  final DateTime? createdAt;
  final CareerPreferencesModel? careerPreferences;

  String get fullName => name;

  factory UserModel.fromMap(
    Map<String, dynamic> map, {
    String uid = '',
  }) {
    final rawCreatedAt = map['createdAt'];
    DateTime? parsedCreatedAt;
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt);
    }

    final rawPrefs = map['careerPreferences'];
    CareerPreferencesModel? parsedPrefs;
    if (rawPrefs is Map<String, dynamic>) {
      parsedPrefs = CareerPreferencesModel.fromJson(rawPrefs);
    }

    return UserModel(
      uid: (map['uid'] as String?) ?? uid,
      name: (map['fullName'] as String?) ?? (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      preferencesCompleted: (map['preferencesCompleted'] as bool?) ?? false,
      createdAt: parsedCreatedAt,
      careerPreferences: parsedPrefs,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'fullName': name,
      'email': email,
      'preferencesCompleted': preferencesCompleted,
      if (careerPreferences != null)
        'careerPreferences': careerPreferences!.toJson(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    bool? preferencesCompleted,
    DateTime? createdAt,
    CareerPreferencesModel? careerPreferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      preferencesCompleted: preferencesCompleted ?? this.preferencesCompleted,
      createdAt: createdAt ?? this.createdAt,
      careerPreferences: careerPreferences ?? this.careerPreferences,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        preferencesCompleted,
        createdAt,
        careerPreferences,
      ];
}
