import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/app_notification_model.dart';

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<AppNotificationModel> notifications;
  final String? errorMessage;

  List<AppNotificationModel> get todayNotifications {
    final now = DateTime.now();
    return notifications.where((n) {
      final local = n.createdAt.toLocal();
      return local.year == now.year &&
          local.month == now.month &&
          local.day == now.day;
    }).toList();
  }

  List<AppNotificationModel> get earlierNotifications {
    final todayIds = todayNotifications.map((e) => e.id).toSet();
    return notifications.where((n) => !todayIds.contains(n.id)).toList();
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        super(const NotificationsState());

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Future<void> loadNotifications() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;

    emit(
      NotificationsState(
        status: NotificationsStatus.loading,
        notifications: state.notifications,
      ),
    );
    try {
      final ref =
          _firestore.collection('users').doc(uid).collection('notifications');
      final snapshot =
          await ref.orderBy('createdAt', descending: true).limit(30).get();

      final list = snapshot.docs
          .map((d) => AppNotificationModel.fromMap(d.data(), id: d.id))
          .toList();

      if (list.isEmpty) {
        await ref.add({
          'title': 'أهلاً بك في رحلتك المهنية',
          'body':
              'ابدأ برفع سيرتك الذاتية (PDF) لاكتشاف أفضل الوظائف المناسبة.',
          'type': 'welcome',
          'targetRoute': '/upload-cv',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        final seeded =
            await ref.orderBy('createdAt', descending: true).limit(10).get();
        if (!isClosed) {
          emit(
            NotificationsState(
              status: NotificationsStatus.loaded,
              notifications: seeded.docs
                  .map((d) => AppNotificationModel.fromMap(d.data(), id: d.id))
                  .toList(),
            ),
          );
        }
        return;
      }

      if (isClosed) return;
      emit(
        NotificationsState(
          status: NotificationsStatus.loaded,
          notifications: list,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        const NotificationsState(
          status: NotificationsStatus.error,
          errorMessage: 'تعذر تحميل الإشعارات.',
        ),
      );
    }
  }
}
