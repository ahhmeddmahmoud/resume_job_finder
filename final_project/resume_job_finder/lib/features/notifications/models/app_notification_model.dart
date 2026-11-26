import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AppNotificationModel extends Equatable {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetRoute,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final String targetRoute;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotificationModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    final rawDate = map['createdAt'];
    DateTime parsed = DateTime.now();
    if (rawDate is Timestamp) {
      parsed = rawDate.toDate();
    } else if (rawDate is String) {
      parsed = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return AppNotificationModel(
      id: id,
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      type: (map['type'] as String?) ?? 'info',
      targetRoute: (map['targetRoute'] as String?) ?? '/home',
      isRead: (map['isRead'] as bool?) ?? false,
      createdAt: parsed,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, body, type, targetRoute, isRead, createdAt];
}
