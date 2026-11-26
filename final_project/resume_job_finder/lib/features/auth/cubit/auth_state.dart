import 'package:equatable/equatable.dart';

import '../models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  registered,
  resetLinkSent,
  passwordResetSuccess,
  loggedOut,
  error,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.resetEmail,
  });

  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String? resetEmail;

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    String? resetEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      resetEmail: resetEmail ?? this.resetEmail,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, resetEmail];
}
