import 'package:flutter_test/flutter_test.dart';
import 'package:miaudota_app/main.dart'; // onde está o modelo PetParaAdocao

void main() {
  test("converter JSON para PetParaAdocao", () {
    // 1️⃣ Lista fake usada apenas no teste
    final List<Map<String, dynamic>> listaJson = [
      {
        'id': 1,
        'nome': 'Tom',
        'descricao': 'Fofo',
        'especie': 'Gato',
        'raca': 'SRD',
        'idade': '2 meses',
        'bairro': 'Centro',
        'cidade': 'Itajaí',
        'estado': 'SC',
        'foto': '',
        'telefoneTutor': '47999999999',
        'usuario_id': 5,
      },
    ];

    final pets = listaJson.map<PetParaAdocao>((json) {
      return PetParaAdocao(
        id: json['id'],
        nome: json['nome']?.toString() ?? '',
        descricao: json['descricao']?.toString() ?? '',
        especie: json['especie']?.toString() ?? '',
        tipo: json['especie']?.toString() ?? '',
        raca: json['raca']?.toString() ?? '',
        idade: json['idade']?.toString() ?? '',
        bairro: json['bairro']?.toString() ?? '',
        cidade: json['cidade']?.toString() ?? '',
        estado: json['estado']?.toString() ?? '',
        imagemPath: 'assets/images/tom.png',
        telefoneTutor: json['telefoneTutor']?.toString() ?? '',
        usuarioId: json['usuario_id'],
      );
    }).toList();

    expect(pets.length, 1);
    expect(pets[0].nome, 'Tom');
    expect(pets[0].tipo, 'Gato');
  });
}
