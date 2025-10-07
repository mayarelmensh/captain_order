import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtils {
  static late SharedPreferences sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveData({required String key, required dynamic value}) {
    if (value is int) {
      return sharedPreferences.setInt(key, value);
    } else if (value is double) {
      return sharedPreferences.setDouble(key, value);
    } else if (value is String) {
      return sharedPreferences.setString(key, value);
    } else {
      return sharedPreferences.setBool(key, value);
    }
  }

  static Object? getData({required String key}) {
    return sharedPreferences.get(key);
  }

  static Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }
}

//
//
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SharedPreferenceUtils {
//   static SharedPreferences? _sharedPreferences;
//
//   static Future<void> init() async {
//     if (_sharedPreferences == null) {
//       print("🛠️ Initializing SharedPreferences...");
//       _sharedPreferences = await SharedPreferences.getInstance();
//       print("✅ SharedPreferences initialized");
//     }
//   }
//
//   static Future<bool> saveData({required String key, required dynamic value}) async {
//     await init(); // تأكد إن SharedPreferences جاهز
//     print("💾 Saving data - Key: $key, Value: $value");
//     if (value is int) {
//       return await _sharedPreferences!.setInt(key, value);
//     } else if (value is double) {
//       return await _sharedPreferences!.setDouble(key, value);
//     } else if (value is String) {
//       return await _sharedPreferences!.setString(key, value);
//     } else if (value is bool) {
//       return await _sharedPreferences!.setBool(key, value);
//     } else {
//       print("❌ Unsupported data type for key: $key, value: $value");
//       return false;
//     }
//   }
//
//   static Future<dynamic> getData({required String key}) async {
//     await init(); // تأكد إن SharedPreferences جاهز
//     final value = _sharedPreferences!.get(key);
//     print("📖 Getting data - Key: $key, Value: $value");
//     return value;
//   }
//
//   static Future<bool> removeData({required String key}) async {
//     await init(); // تأكد إن SharedPreferences جاهز
//     final result = await _sharedPreferences!.remove(key);
//     print("🗑️ Removed key: $key, Success: $result");
//     return result;
//   }
//
//   static Future<bool> clearAll() async {
//     await init(); // تأكد إن SharedPreferences جاهز
//     final result = await _sharedPreferences!.clear();
//     print("🗑️ Cleared all SharedPreferences: $result");
//     return result;
//   }
// }
