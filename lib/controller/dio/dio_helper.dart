import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioHelper {
  static Dio? dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://bcknd.food2go.online',
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for detailed logging
    dio!.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => log('🌐 DIO: $obj'),
      ),
    );

    // Add token interceptor for automatic token management
    dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.headers.containsKey('Authorization')) {
            final token = await getStoredToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          log('🔥 DIO Error: ${error.message}');
          log('🔥 Response: ${error.response?.data}');
          log('🔥 Status Code: ${error.response?.statusCode}');

          if (error.response?.statusCode == 401) {
            log('🔒 Token expired or invalid - clearing stored token');
            await clearStoredToken();
          }

          handler.next(error);
        },
      ),
    );
  }

  static Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      log('❌ Error getting stored token: $e');
      return null;
    }
  }

  static Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('token', token);
    } catch (e) {
      log('❌ Error saving token: $e');
      return false;
    }
  }

  static Future<bool> clearStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('token');
    } catch (e) {
      log('❌ Error clearing token: $e');
      return false;
    }
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    Options? options,
    String? token,
  }) async {
    try {
      // Add authorization header if token provided
      final finalOptions = options ?? Options();
      if (token != null) {
        finalOptions.headers = {
          ...?finalOptions.headers,
          'Authorization': 'Bearer $token',
        };
      }

      log('📤 GET Request: ${dio!.options.baseUrl}$url');
      if (query != null) log('📤 Query Parameters: $query');

      return await dio!.get(
        url,
        queryParameters: query,
        options: finalOptions,
      );
    } catch (e) {
      log('❌ DioHelper getData Error: $e');
      rethrow;
    }
  }

  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    Options? options,
    String? token,
  }) async {
    try {
      final finalOptions = options ?? Options();
      if (token != null) {
        finalOptions.headers = {
          ...?finalOptions.headers,
          'Authorization': 'Bearer $token',
        };
      }

      log('📤 POST Request: ${dio!.options.baseUrl}$url');
      if (data != null) log('📤 POST Data: $data');

      return await dio!.post(
        url,
        data: data,
        queryParameters: query,
        options: finalOptions,
      );
    } catch (e) {
      log('❌ DioHelper postData Error: $e');
      rethrow;
    }
  }

  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    Options? options,
    String? token,
  }) async {
    try {
      final finalOptions = options ?? Options();
      if (token != null) {
        finalOptions.headers = {
          ...?finalOptions.headers,
          'Authorization': 'Bearer $token',
        };
      }

      log('📤 PUT Request: ${dio!.options.baseUrl}$url');
      if (data != null) log('📤 PUT Data: $data');

      return await dio!.put(
        url,
        data: data,
        queryParameters: query,
        options: finalOptions,
      );
    } catch (e) {
      log('❌ DioHelper putData Error: $e');
      rethrow;
    }
  }
}