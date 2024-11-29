import 'package:dio/dio.dart';

import 'api_client.dart';

abstract class ApiModule {
  Dio get dio;
  ApiClient get client;
}