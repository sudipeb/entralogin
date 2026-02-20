abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String name;
  final String email;
  final dynamic profilePhoto;

  AuthSuccess(this.profilePhoto, this.name, this.email);
}

class AuthError extends AuthState {
  final String errorMessage;
  AuthError(this.errorMessage);
}
