import 'dart:ffi';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../../controller/cache/shared_preferences_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../controller/dio/dio_helper.dart';
import '../../../../../controller/errors/failures.dart';
import '../model/login_model.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial()) {
    // تحميل البيانات المحفوظة عند إنشاء الـ Cubit
    loadSavedData();
  }

  bool isPasswordObscure = true;
  String? captainName;
  String? captainId;
  String? captainImageLink;
  LoginResponse? loginResponse;

  Future<void> loadSavedData() async {
    try {
      captainName = await SharedPreferenceUtils.getData(key: 'captainName')as String;
      captainId = await SharedPreferenceUtils.getData(key: 'captainId')as String;
      captainImageLink = await SharedPreferenceUtils.getData(key: 'captainImage')as String;

      print("📂 Loaded saved data:");
      print("👤 Captain Name: $captainName");
      print("🆔 Captain ID: $captainId");
      print("🖼️ Captain Image: $captainImageLink");

      if (captainName != null || captainId != null || captainImageLink != null) {
        emit(ChangePasswordVisibilityState()); // emit أي state عشان الـ UI يتحديث
      }
    } catch (e) {
      print("⚠️ Error loading saved data: $e");
    }
  }

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
        loginResponse = LoginResponse.fromJson(response.data);

        // ✅ استخدام captainOrder (اللي جاي من user في الـ API)
        captainName = loginResponse!.captainOrder?.userName ?? userName;
        captainId = loginResponse!.captainOrder?.id?.toString() ?? '';
        captainImageLink = loginResponse!.captainOrder?.imageLink ?? '';

        await SharedPreferenceUtils.saveData(key: 'captainName', value: captainName);
        await SharedPreferenceUtils.saveData(key: 'captainId', value: captainId);
        await SharedPreferenceUtils.saveData(key: 'captainImage', value: captainImageLink);

        // حفظ التوكن
        await SharedPreferenceUtils.saveData(
          key: 'token',
          value: loginResponse!.token,
        );

        print("✅ Role from API: ${loginResponse!.role}");
        print("✅ User Role: ${loginResponse!.captainOrder?.role}");
        print("✅ Captain Name: $captainName");
        print("✅ Captain Image: $captainImageLink");

        emit(LoginSuccess(loginResponse!));
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

  void logout() {
    captainName = null;
    captainId = null;
    captainImageLink = null;
    loginResponse = null;
    SharedPreferenceUtils.removeData(key: 'token');
    SharedPreferenceUtils.removeData(key: 'captainName');
    SharedPreferenceUtils.removeData(key: 'captainId');
    SharedPreferenceUtils.removeData(key: 'captainImage');
    emit(LoginInitial());
  }

  // ✅ إضافة methods مساعدة للوصول للبيانات - مع safe navigation
  String get currentCaptainName => loginResponse?.captainOrder?.name ?? captainName ?? "Captain";
  String get currentCaptainId => loginResponse?.captainOrder?.id?.toString() ?? captainId ?? "1";
  String? get currentCaptainImage => loginResponse?.captainOrder?.imageLink ?? captainImageLink;
  String get currentUserRole => loginResponse?.captainOrder?.role ?? "captain_order";

  // إضافة method لإجبار تحديث الـ UI
  void refreshUI() {
    emit(ChangePasswordVisibilityState());
  }
}