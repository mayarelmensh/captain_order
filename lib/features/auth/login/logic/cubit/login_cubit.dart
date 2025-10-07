import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../../controller/cache/shared_preferences_utils.dart';
import '../../../../../controller/dio/dio_helper.dart';
import '../../../../../controller/errors/failures.dart';
import '../model/login_model.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial()) {
    loadSavedData();
  }

  bool isPasswordObscure = true;
  String? captainName;
  String? captainId;
  String? captainImageLink;
  String? role;
  LoginResponse? loginResponse;

  Future<void> loadSavedData() async {
    try {
      captainName = await SharedPreferenceUtils.getData(key: 'captainName') as String?;
      captainId = await SharedPreferenceUtils.getData(key: 'captainId') as String?;
      captainImageLink = await SharedPreferenceUtils.getData(key: 'captainImage') as String?;
      String? savedToken = await SharedPreferenceUtils.getData(key: 'token') as String?;
      String? savedRole = await SharedPreferenceUtils.getData(key: 'role') as String?;
      String? savedWaiter = await SharedPreferenceUtils.getData(key: 'waiter_status') as String?;

      if (savedToken != null && savedRole != null) {
        loginResponse = LoginResponse(
          token: savedToken,
          role: savedRole,
          captainOrder: CaptainOrder(
            id: int.tryParse(captainId ?? ''),
            name: captainName,
            userName: captainName,
            imageLink: captainImageLink,
            role: savedRole,
            waiter: int.tryParse(savedWaiter ?? '0'),
          ),
        );
        role = savedRole;
      }

      print("📂 Loaded saved data:");
      print("👤 Captain Name: $captainName");
      print("🆔 Captain ID: $captainId");
      print("🖼️ Captain Image: $captainImageLink");
      print("🔑 Has saved token: ${savedToken != null}");
      print("🎭 Role: $savedRole");
      print("🍽️ Waiter Status (from cache): $savedWaiter");

      if (captainName != null || captainId != null || captainImageLink != null || role != null) {
        emit(ChangePasswordVisibilityState());
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
      print("📱 FCM Token: $fcmToken");

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
        print("🔑 Token: ${loginResponse?.token}");
        print("🎭 Role: ${loginResponse?.role}");
        print("👤 User exists: ${loginResponse?.captainOrder != null}");
        print("🍽️ Waiter value: ${loginResponse?.captainOrder?.waiter}");

        captainName = loginResponse!.captainOrder?.userName ?? userName;
        captainId = loginResponse!.captainOrder?.id?.toString() ?? '';
        captainImageLink = loginResponse!.captainOrder?.imageLink ?? '';
        role = loginResponse!.role ?? loginResponse!.captainOrder?.role ?? 'captain_order';

        await SharedPreferenceUtils.saveData(key: 'captainName', value: captainName);
        await SharedPreferenceUtils.saveData(key: 'captainId', value: captainId);
        await SharedPreferenceUtils.saveData(key: 'captainImage', value: captainImageLink);
        await SharedPreferenceUtils.saveData(key: 'token', value: loginResponse!.token);
        await SharedPreferenceUtils.saveData(key: 'role', value: role);
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

  Future<void> logout() async {
    // ❌ امسح الـ emit(LoginLoading()) دي - مش محتاجينها
    // emit(LoginLoading());

    try {
      captainName = null;
      captainId = null;
      captainImageLink = null;
      role = null;
      loginResponse = null;

      await SharedPreferenceUtils.removeData(key: 'token');
      await SharedPreferenceUtils.removeData(key: 'captainName');
      await SharedPreferenceUtils.removeData(key: 'captainId');
      await SharedPreferenceUtils.removeData(key: 'captainImage');
      await SharedPreferenceUtils.removeData(key: 'role');
      await SharedPreferenceUtils.removeData(key: 'waiter_status');

      // ✅ ده كفاية
      emit(LoginInitial());
    } catch (e) {
      print("⚠️ Logout Exception: $e");
      emit(LoginError(ServerError(errorMsg: 'Failed to logout: $e')));
    }
  }
  String get currentCaptainName => loginResponse?.captainOrder?.name ?? captainName ?? "Captain";
  String get currentCaptainId => loginResponse?.captainOrder?.id?.toString() ?? captainId ?? "1";
  String? get currentCaptainImage => loginResponse?.captainOrder?.imageLink ?? captainImageLink;
  String get currentUserRole => loginResponse?.role ?? role ?? "captain_order";
  int get currentWaiterStatus => loginResponse?.captainOrder?.waiter ?? 0;

  void refreshUI() {
    if (loginResponse != null) {
      emit(LoginSuccess(loginResponse!));
    } else {
      emit(ChangePasswordVisibilityState());
    }
  }
}