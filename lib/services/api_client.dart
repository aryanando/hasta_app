import 'package:dio/dio.dart';
import 'package:hasta_app/services/helper/shared_perference_helper.dart';

class ApiClient {
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;

  ApiClient._internal() {
    // Set up Dio with base options
    BaseOptions options = BaseOptions(
      baseUrl:
          '${const String.fromEnvironment('devUrl')}api/v1', // Replace with your API's base URL
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 5000),
    );
    dio = Dio(options);

    // Add an interceptor to attach the auth token from SharedPreferences to each request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Retrieve token from SharedPreferences
          String? token = await SharedPrefHelper.getToken();
          print(token);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Optionally process the response
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          // Optionally handle errors (e.g., token refresh logic)
          return handler.next(error);
        },
      ),
    );
  }

  // Helper method for GET requests
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);

      return response;
    } catch (e) {
      throw Exception('GET request error: $e');
    }
  }

  // Helper method for POST requests
  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await dio.post(path, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw Exception('POST request error: $e');
    }
  }
}
