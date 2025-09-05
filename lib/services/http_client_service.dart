import 'package:dio/dio.dart';

class HttpClientService {
  final Dio _dio;
  final String baseUrl = 'http://localhost:8081/json-proxy';

  HttpClientService(this._dio);

  Future<dynamic> get(String path) async {
    try {
      final response = await _dio.get('$baseUrl$path');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to perform GET request: ${e.message}');
    }
  }

  Future<dynamic> post(String path, dynamic data) async {
    try {
      final response = await _dio.post('$baseUrl$path', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to perform POST request: ${e.message}');
    }
  }

  Future<dynamic> put(String path, dynamic data) async {
    try {
      final response = await _dio.put('$baseUrl$path', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to perform PUT request: ${e.message}');
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete('$baseUrl$path');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to perform DELETE request: ${e.message}');
    }
  }
}