import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

import 'services/http_client_service.dart';
import 'services/client_service.dart';
import 'controllers/theme_controller.dart';
import 'pages/client_page.dart';
import 'pages/edit_client_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Register Dio and HttpClientService
  Get.put(Dio());
  Get.put(HttpClientService(Get.find<Dio>()));

  // Register ClientService
  Get.put(ClientService(Get.find<HttpClientService>()));

  // Register ThemeController
  Get.put(ThemeController());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Rayquaza Web App',
      debugShowCheckedModeBanner: false,
      themeMode: themeController.themeMode,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(color: Colors.blue),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        appBarTheme: const AppBarTheme(color: Colors.indigo),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const ClientPage()),
        GetPage(name: '/create', page: () => const EditClient()),
        GetPage(name: '/edit', page: () => EditClient(entity: Get.arguments)),
      ],
    );
  }
}