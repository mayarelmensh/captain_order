import '../../../../../core/errors/failures.dart';
import '../model/login_model.dart';


abstract class LoginState {}

class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final LoginResponse loginResponse;
  LoginSuccess(this.loginResponse);
}
class LoginError extends LoginState {
  final Failures failure;
  LoginError(this.failure);
}