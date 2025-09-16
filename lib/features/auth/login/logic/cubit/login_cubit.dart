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


}
