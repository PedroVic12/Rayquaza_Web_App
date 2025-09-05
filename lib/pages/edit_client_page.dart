import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/client_controller.dart';
import '../dtos/client_dto.dart';
import '../entities/client_entity.dart';
import '../widgets/text_input.dart';
import '../adapters/client_adapter.dart';

class EditClient extends StatefulWidget {
  final ClientEntity? entity;
  const EditClient({
    super.key,
    this.entity,
  });

  @override
  State<EditClient> createState() => _EditClientState();
}

class _EditClientState extends State<EditClient> {
  late ClientDTO dto;
  final ClientController clientController = Get.find<ClientController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  bool get editable => widget.entity != null;

  @override
  void initState() {
    super.initState();
    if (widget.entity != null) {
      dto = ClientAdapter.entityToDTO(widget.entity!);
      nameController.text = dto.name ?? '';
      emailController.text = dto.email ?? '';
      detailsController.text = dto.details ?? '';
    } else {
      dto = ClientDTO();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  void _save() async {
    dto.name = nameController.text;
    dto.email = emailController.text;
    dto.details = detailsController.text;

    if (!dto.isValid()) {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (editable) {
      await clientController.updateClient(dto);
    } else {
      await clientController.createClient(dto);
    }
  }

  void _clear() {
    setState(() {
      dto = ClientDTO(id: dto.id);
      nameController.clear();
      emailController.clear();
      detailsController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editable ? 'Edit Client' : 'Create Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextInput(
              controller: nameController,
              hint: 'Nome',
              validator: dto.nameValidate,
            ),
            const SizedBox(height: 5),
            TextInput(
              controller: emailController,
              hint: 'Email',
              validator: dto.emailValidate,
            ),
            const SizedBox(height: 5),
            TextInput(
              controller: detailsController,
              hint: 'Detalhes',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Salvar'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _clear,
                  child: const Text('Limpar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}