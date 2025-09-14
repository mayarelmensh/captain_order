import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // 👈 مهم عشان نجيب الـ FCM Token
import '../../../../../controller/dio/dio_helper.dart';
import '../../../../../controller/errors/failures.dart';
import '../model/login_model.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  bool isPasswordObscure = true;

  void togglePasswordVisibility() {
    isPasswordObscure = !isPasswordObscure;
    emit(ChangePasswordVisibilityState());
  }

  Future<void> login(String userName, String password) async {
    emit(LoginLoading());
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print("FCM Token: $fcmToken");

      final response = await DioHelper.postData(
        query: {
          "user_name": userName,
          "password": password,
          "fcm_token": fcmToken ?? "",
        },
        url: '/api/captain/auth/login',
      );

      print("📦 Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data['user'] != null) {
        // Parse safely
        final loginResponse = LoginResponse.fromJson(response.data);
        emit(LoginSuccess(loginResponse));
      } else {
        emit(LoginError(ServerError(
            errorMsg: 'Login failed: Unexpected response from server')));
      }
    } catch (e) {
      print("⚠️ Login Exception: $e");
      emit(LoginError(ServerError(
          errorMsg: 'Something went wrong, please check user name or password and try again')));
    }
  }


  //
  // void _handleErrorResponse(Response response) {
  //   String errorMsg = 'An error occurred';
  //   switch (response.statusCode) {
  //     case 400:
  //       emit(LoginError(ValidationFailure(errorMsg: 'Invalid email or password')));
  //       break;
  //     case 401:
  //       emit(LoginError(UnauthorizedFailure(errorMsg: 'Unauthorized access')));
  //       break;
  //     case 404:
  //       emit(LoginError(NotFoundFailure(errorMsg: 'Endpoint not found')));
  //       break;
  //     case 500:
  //     default:
  //       emit(LoginError(ServerError(errorMsg: 'Server error: ${response.statusMessage ?? errorMsg}')));
  //       break;
  //   }
  // }
  //
  // void _handleException(dynamic e) {
  //   if (e.toString().contains('SocketException') || e.toString().contains('Timeout')) {
  //     emit(LoginError(NetworkError(errorMsg: 'Please check your internet connection')));
  //   } else {
  //     emit(LoginError(ServerError(errorMsg: 'Something went wrong, please try again')));
  //   }
  // }
}
