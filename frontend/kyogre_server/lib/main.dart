import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Servidor Kyogre',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Servidor Kyogre'),
        ),
        body: Center(
          child: Text('Server is running...'),
        ),
      ),
    );
  }
}

class ServerController extends GetxController {
  void startServer() async {
    var server = await HttpServer.bind('localhost', 8080);
    print('Server listening on localhost:${server.port}');
    await for (var request in server) {
      request.response
        ..headers.contentType = ContentType.html
        ..write('Hello, world!')
        ..close();
    }
  }
}
