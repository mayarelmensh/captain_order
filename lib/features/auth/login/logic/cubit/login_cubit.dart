import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../../controller/cache/shared_preferences_utils.dart';
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
      captainName = await SharedPreferenceUtils.getData(key: 'captainName') as String?;
      captainId = await SharedPreferenceUtils.getData(key: 'captainId') as String?;
      captainImageLink = await SharedPreferenceUtils.getData(key: 'captainImage') as String?;
      String? savedToken = await SharedPreferenceUtils.getData(key: 'token') as String?;
      String? savedWaiter = await SharedPreferenceUtils.getData(key: 'waiter_status') as String?;

      if (savedToken != null && captainName != null) {
        // إنشاء LoginResponse مؤقتة من البيانات المحفوظة
        loginResponse = LoginResponse(
          token: savedToken,
          role: 'captain_order',
          captainOrder: CaptainOrder(
            id: int.tryParse(captainId ?? ''),
            name: captainName,
            userName: captainName,
            imageLink: captainImageLink,
            role: 'captain_order',
            waiter: int.tryParse(savedWaiter ?? '0'), // 👈 خدها من الكاش
          ),
        );
      }

      print("📂 Loaded saved data:");
      print("👤 Captain Name: $captainName");
      print("🆔 Captain ID: $captainId");
      print("🖼️ Captain Image: $captainImageLink");
      print("🔑 Has saved token: ${savedToken != null}");
      print("🍽️ Waiter Status (from cache): $savedWaiter");

      // refresh من السيرفر بعد التحميل من الكاش
      if (savedToken != null) {
        await refreshUserData();
      }

      if (captainName != null || captainId != null || captainImageLink != null) {
        emit(ChangePasswordVisibilityState()); // emit أي state عشان الـ UI يتحدث
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
        loginResponse = LoginResponse.fromJson(response.data);

        print("🔍 LoginResponse created successfully:");
        print("Token: ${loginResponse?.token}");
        print("Role: ${loginResponse?.role}");
        print("User exists: ${loginResponse?.captainOrder != null}");
        print("Waiter value: ${loginResponse?.captainOrder?.waiter}");

        captainName = loginResponse!.captainOrder?.userName ?? userName;
        captainId = loginResponse!.captainOrder?.id?.toString() ?? '';
        captainImageLink = loginResponse!.captainOrder?.imageLink ?? '';

        await SharedPreferenceUtils.saveData(key: 'captainName', value: captainName);
        await SharedPreferenceUtils.saveData(key: 'captainId', value: captainId);
        await SharedPreferenceUtils.saveData(key: 'captainImage', value: captainImageLink);

        await SharedPreferenceUtils.saveData(key: 'token', value: loginResponse!.token);

        await SharedPreferenceUtils.saveData(
          key: 'waiter_status',
          value: loginResponse!.captainOrder?.waiter?.toString() ?? '0',
        );

        print("✅ Role from API: ${loginResponse!.role}");
        print("✅ User Role: ${loginResponse!.captainOrder?.role}");
        print("✅ Captain Name: $captainName");
        print("✅ Captain Image: $captainImageLink");
        print("✅ Waiter Status: ${loginResponse!.captainOrder?.waiter}");

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
    SharedPreferenceUtils.removeData(key: 'waiter_status');
    emit(LoginInitial());
  }

  // ✅ Getters
  String get currentCaptainName => loginResponse?.captainOrder?.name ?? captainName ?? "Captain";
  String get currentCaptainId => loginResponse?.captainOrder?.id?.toString() ?? captainId ?? "1";
  String? get currentCaptainImage => loginResponse?.captainOrder?.imageLink ?? captainImageLink;
  String get currentUserRole => loginResponse?.captainOrder?.role ?? "captain_order";
  int get currentWaiterStatus => loginResponse?.captainOrder?.waiter ?? 0;

  void refreshUI() {
    if (loginResponse != null) {
      emit(LoginSuccess(loginResponse!));
    } else {
      emit(ChangePasswordVisibilityState());
    }
  }

  Future<void> refreshUserData() async {
    if (loginResponse?.token == null) return;

    try {
      final response = await DioHelper.getData(
        url: '/api/captain/profile',
        token: loginResponse!.token,
      );

      if (response.statusCode == 200 && response.data['user'] != null) {
        loginResponse = LoginResponse.fromJson({
          'user': response.data['user'],
          'token': loginResponse!.token,
          'role': loginResponse!.role,
        });

        // تحديث الكاش
        await SharedPreferenceUtils.saveData(
          key: 'waiter_status',
          value: loginResponse!.captainOrder?.waiter?.toString() ?? '0',
        );

        print("🔄 User data refreshed:");
        print("Waiter Status: ${loginResponse?.captainOrder?.waiter}");

        emit(LoginSuccess(loginResponse!));
      }
    } catch (e) {
      print("⚠️ Error refreshing user data: $e");
    }
  }
}
