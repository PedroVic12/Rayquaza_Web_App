import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



// ===================== MODEL =====================
class ClientModel {
  final int id;
  final String name;
  final String email;

  ClientModel({required this.id, required this.name, required this.email});

  factory ClientModel.fromJson(Map<String, dynamic> json) =>
      ClientModel(id: json['id'], name: json['name'], email: json['email']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

// ===================== REPOSITORY =====================
class ClientRepository {
  final Dio dio = Dio();
  final GetStorage storage = GetStorage();
  static const String storageKey = 'clients';
  Database? _db;

  // --- GetStorage (rápido/local) ---
  List<ClientModel> getClientsFromStorage() {
    final data = storage.read<List>(storageKey) ?? [];
    return data.map((e) => ClientModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveClientsToStorage(List<ClientModel> clients) async {
    final data = clients.map((e) => e.toJson()).toList();
    await storage.write(storageKey, data);
  }

  // --- SQLite (backup local) ---
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'clients.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE clients(id INTEGER PRIMARY KEY, name TEXT, email TEXT)',
        );
      },
      version: 1,
    );
    return _db!;
  }

  Future<void> backupToSqlite(List<ClientModel> clients) async {
    final database = await db;
    await database.delete('clients');
    for (var client in clients) {
      await database.insert('clients', client.toJson());
    }
  }

  Future<List<ClientModel>> restoreFromSqlite() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query('clients');
    return List.generate(maps.length, (i) => ClientModel.fromJson(maps[i]));
  }

  // --- CRUD (usando GetStorage como principal, SQLite como backup) ---
  Future<List<ClientModel>> getClients() async {
    // Tenta GetStorage, se vazio tenta SQLite
    var clients = getClientsFromStorage();
    if (clients.isEmpty) {
      clients = await restoreFromSqlite();
      await saveClientsToStorage(clients);
    }
    return clients;
  }

  Future<void> addClient(ClientModel client) async {
    final clients = getClientsFromStorage();
    clients.add(client);
    await saveClientsToStorage(clients);
    await backupToSqlite(clients);
  }

  Future<void> updateClient(ClientModel client) async {
    final clients = getClientsFromStorage();
    final idx = clients.indexWhere((c) => c.id == client.id);
    if (idx != -1) clients[idx] = client;
    await saveClientsToStorage(clients);
    await backupToSqlite(clients);
  }

  Future<void> deleteClient(int id) async {
    final clients = getClientsFromStorage();
    clients.removeWhere((c) => c.id == id);
    await saveClientsToStorage(clients);
    await backupToSqlite(clients);
  }

  // --- Exemplo de requisição HTTP (Dio) ---
  Future<List<ClientModel>> fetchClientsFromApi() async {
    final response = await dio.get('https://jsonplaceholder.typicode.com/users');
    return (response.data as List).map((e) => ClientModel.fromJson(e)).toList();
  }
}

// ===================== CONTROLLER =====================
class ClientController extends GetxController {
  final ClientRepository repository = ClientRepository();
  var clients = <ClientModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadClients();
  }

  Future<void> loadClients() async {
    clients.value = await repository.getClients();
  }

  Future<void> addClient(ClientModel client) async {
    await repository.addClient(client);
    await loadClients();
  }

  Future<void> updateClient(ClientModel client) async {
    await repository.updateClient(client);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await repository.deleteClient(id);
    await loadClients();
  }

  Future<void> backupFromApi() async {
    final apiClients = await repository.fetchClientsFromApi();
    for (var client in apiClients) {
      await repository.addClient(client);
    }
    await loadClients();
  }
}

// ===================== VIEWS =====================

// --- Lista de Clientes ---
class ClientListView extends StatelessWidget {
  final ClientController controller = Get.put(ClientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_download),
            tooltip: 'Backup da API',
            onPressed: () async {
              await controller.backupFromApi();
              Get.snackbar('Backup', 'Clientes da API salvos localmente!');
            },
          ),
        ],
      ),
      body: Obx(() => ListView.builder(
            itemCount: controller.clients.length,
            itemBuilder: (context, index) {
              final client = controller.clients[index];
              return ListTile(
                title: Text(client.name),
                subtitle: Text(client.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        final updated = await Get.to(() => ClientFormView(client: client));
                        if (updated != null) controller.loadClients();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await controller.deleteClient(client.id);
                      },
                    ),
                  ],
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Get.to(() => ClientFormView());
          if (created != null) controller.loadClients();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// --- Formulário de Cliente ---
class ClientFormView extends StatefulWidget {
  final ClientModel? client;
  ClientFormView({this.client, Key? key}) : super(key: key);

  @override
  State<ClientFormView> createState() => _ClientFormViewState();
}

class _ClientFormViewState extends State<ClientFormView> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String email;
  final ClientController controller = Get.find();

  @override
  void initState() {
    super.initState();
    name = widget.client?.name ?? '';
    email = widget.client?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.client == null ? 'Novo Cliente' : 'Editar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                onSaved: (v) => name = v ?? '',
              ),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o email' : null,
                onSaved: (v) => email = v ?? '',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final client = ClientModel(
                      id: widget.client?.id ?? DateTime.now().millisecondsSinceEpoch,
                      name: name,
                      email: email,
                    );
                    if (widget.client == null) {
                      await controller.addClient(client);
                    } else {
                      await controller.updateClient(client);
                    }
                    Get.back(result: true);
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== MAIN =====================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(GetMaterialApp(
    title: 'Cadastro de Clientes',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: ClientListView(),
  ));
}