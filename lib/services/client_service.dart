import 'package:cadastro_asp/adapters/client_adapter.dart';
import 'package:cadastro_asp/dtos/client_dto.dart';
import 'package:cadastro_asp/entities/client_entity.dart';

import 'http_client_service.dart';

class ClientService {
  final HttpClientService client;

  ClientService(this.client);

  Future<List<ClientEntity>> fetchClients() async {
    final response = await client.get('/clients');
    return (response as List).map(ClientAdapter.fromMap).toList();
  }

  Future<void> createClient(ClientDTO dto) async {
    final data = ClientAdapter.dtoToMap(dto);
    await client.post('/clients', data);
  }

  Future<void> updateClient(ClientDTO dto) async {
    final data = ClientAdapter.dtoToMap(dto);
    await client.put('/clients/${dto.id}', data);
  }

  Future<void> deleteClient(String id) async {
    await client.delete('/clients/$id');
  }
}
