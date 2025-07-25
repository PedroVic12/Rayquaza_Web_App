import 'package:get/get.dart';
import 'package:kyogre_server/models/Agendamento.dart';


class AgendamentosController extends GetxController {
  final _agendamentos = <Agendamento>[].obs;

  List<Agendamento> get agendamentos => _agendamentos;

  void addAgendamento(Agendamento agendamento) {
    _agendamentos.add(agendamento);
  }

  void updateAgendamento(int index, Agendamento agendamento) {
    _agendamentos[index] = agendamento;
  }

  void deleteAgendamento(int index) {
    _agendamentos.removeAt(index);
  }
}
