import 'package:vaden/vaden.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:shelf/shelf.dart' as shelf_lib; // Alias shelf for its Response and Request types

@Controller('/json-proxy')
class JsonProxyController {
  final dio_lib.Dio _dio;

  JsonProxyController(this._dio);

  @Get('/clients')
  Future<Response> getClients(shelf_lib.Request request) async {
    try {
      final response = await _dio.get('http://localhost:3000/clients');
      return shelf_lib.Response.ok(response.data, headers: {'Content-Type': 'application/json'});
    } on dio_lib.DioException catch (e) {
      return shelf_lib.Response.internalServerError(body: {'error': e.message});
    }
  }

  @Get('/clients/:id')
  Future<Response> getClientById(shelf_lib.Request request) async {
    final id = request.params['id'];
    try {
      final response = await _dio.get('http://localhost:3000/clients/$id');
      return shelf_lib.Response.ok(response.data, headers: {'Content-Type': 'application/json'});
    } on dio_lib.DioException catch (e) {
      return shelf_lib.Response.internalServerError(body: {'error': e.message});
    }
  }

  @Post('/clients')
  Future<Response> createClient(shelf_lib.Request request) async {
    try {
      final response = await _dio.post('http://localhost:3000/clients', data: await request.readAsString());
      return shelf_lib.Response.ok(response.data, headers: {'Content-Type': 'application/json'});
    } on dio_lib.DioException catch (e) {
      return shelf_lib.Response.internalServerError(body: {'error': e.message});
    }
  }

  @Put('/clients/:id')
  Future<Response> updateClient(shelf_lib.Request request) async {
    final id = request.params['id'];
    try {
      final response = await _dio.put('http://localhost:3000/clients/$id', data: await request.readAsString());
      return shelf_lib.Response.ok(response.data, headers: {'Content-Type': 'application/json'});
    } on dio_lib.DioException catch (e) {
      return shelf_lib.Response.internalServerError(body: {'error': e.message});
    }
  }

  @Delete('/clients/:id')
  Future<Response> deleteClient(shelf_lib.Request request) async {
    final id = request.params['id'];
    try {
      final response = await _dio.delete('http://localhost:3000/clients/$id');
      return shelf_lib.Response.ok(response.data, headers: {'Content-Type': 'application/json'});
    } on dio_lib.DioException catch (e) {
      return shelf_lib.Response.internalServerError(body: {'error': e.message});
    }
  }
}
