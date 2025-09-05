import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/client_controller.dart';
import '../controllers/theme_controller.dart';
import '../entities/client_entity.dart';

class ClientPage extends StatelessWidget {
  const ClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ClientController clientController = Get.put(ClientController());
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: Icon(themeController.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeController.switchTheme();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (clientController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (clientController.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(clientController.errorMessage.value),
                ElevatedButton(
                  onPressed: () => clientController.fetchClients(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (clientController.clients.isEmpty) {
          return const Center(child: Text('No clients found. Add a new one!'));
        } else {
          return ListView.builder(
            itemCount: clientController.clients.length,
            itemBuilder: (_, index) {
              final client = clientController.clients[index];
              return ListTile(
                onTap: () {
                  Get.toNamed('/edit', arguments: client);
                },
                title: Text(client.name),
                subtitle: Text(client.email),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Delete Client',
                      middleText: 'Are you sure you want to delete ${client.name}?',
                      textConfirm: 'Delete',
                      textCancel: 'Cancel',
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        clientController.deleteClient(client.id);
                        Get.back();
                      },
                    );
                  },
                ),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}