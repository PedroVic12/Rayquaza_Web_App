import 'package:get/get.dart';
import '../services/client_service.dart';
import '../entities/client_entity.dart';
import '../dtos/client_dto.dart';

class ClientController extends GetxController {
  final ClientService _clientService = Get.find<ClientService>();

  var clients = <ClientEntity>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClients();
  }

  Future<void> fetchClients() async {
    try {
      isLoading(true);
      errorMessage('');
      final fetchedClients = await _clientService.fetchClients();
      clients.assignAll(fetchedClients);
    } catch (e) {
      errorMessage('Failed to load clients: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> createClient(ClientDTO dto) async {
    try {
      isLoading(true);
      errorMessage('');
      await _clientService.createClient(dto);
      await fetchClients(); // Refresh list after creation
      Get.back(); // Go back to client list
    } catch (e) {
      errorMessage('Failed to create client: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateClient(ClientDTO dto) async {
    try {
      isLoading(true);
      errorMessage('');
      await _clientService.updateClient(dto);
      await fetchClients(); // Refresh list after update
      Get.back(); // Go back to client list
    } catch (e) {
      errorMessage('Failed to update client: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      isLoading(true);
      errorMessage('');
      await _clientService.deleteClient(id);
      await fetchClients(); // Refresh list after deletion
    } catch (e) {
      errorMessage('Failed to delete client: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
}
