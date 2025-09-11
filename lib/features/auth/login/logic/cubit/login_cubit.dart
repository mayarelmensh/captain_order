import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../controller/dio/dio_helper.dart';
import '../../../../../controller/errors/failures.dart';
import '../model/login_model.dart';
import 'login_states.dart';


class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  bool isPasswordObscure = true;

  void togglePasswordVisibility() {
    isPasswordObscure = !isPasswordObscure;
    emit(LoginInitial()); // Trigger rebuild for UI
  }

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final response = await DioHelper.postData
        (data: {
        'email': email,
        'password': password,
      }, url: '/parent/sign_in');

        // endPoint: '/parent/sign_in', // Adjust endpoint as needed
        // body: {
        //   'email': email,
        //   'password': password,
        // },


      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        emit(LoginSuccess(loginResponse));
      } else {
        // Handle non-200 responses
        _handleErrorResponse(response);
      }
    } catch (e) {
      // Handle all errors in a simple way
      _handleException(e);
    }
  }

  void _handleErrorResponse(Response response) {
    String errorMsg = 'An error occurred';
    switch (response.statusCode) {
      case 400:
        emit(LoginError(ValidationFailure(errorMsg: 'Invalid email or password')));
        break;
      case 401:
        emit(LoginError(UnauthorizedFailure(errorMsg: 'Unauthorized access')));
        break;
      case 404:
        emit(LoginError(NotFoundFailure(errorMsg: 'Endpoint not found')));
        break;
      case 500:
      default:
        emit(LoginError(ServerError(errorMsg: 'Server error: ${response.statusMessage ?? errorMsg}')));
        break;
    }
  }

  void _handleException(dynamic e) {
    // Simple error handling: check if it's a network issue or general error
    if (e.toString().contains('SocketException') || e.toString().contains('Timeout')) {
      emit(LoginError(NetworkError(errorMsg: 'Please check your internet connection')));
    } else {
      emit(LoginError(ServerError(errorMsg: 'Something went wrong, please try again')));
    }
  }
}