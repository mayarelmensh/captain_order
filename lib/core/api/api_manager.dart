import 'package:dio/dio.dart';

import 'api_constants.dart';

class ApiManager{
//https://login.mathshouse.net/parent/sign_up
final dio=Dio();

Future<Response>getData({required String endPoint ,Map<String, dynamic>? queryParameters,Options? options}){
 return dio.get(ApiConstants.baseUrl+endPoint,
  queryParameters: queryParameters,
  options: options
  );
}

Future<Response>postData({required String endPoint,Object? body,Map<String, dynamic>? queryParameters,Options? options}){
  return dio.post(ApiConstants.baseUrl+endPoint,
  data: body,
  options: options,
  queryParameters: queryParameters,
  );
}
}