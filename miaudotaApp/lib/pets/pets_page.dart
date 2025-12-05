import 'dart:io';
import 'package:flutter/material.dart';
import 'package:miaudota_app/main.dart'; // PetParaAdocao
import 'package:miaudota_app/services/pet_service.dart';

class PetsPage extends StatefulWidget {
  /// Permite injetar uma função customizada para carregar pets (ex: em testes)
  final Future<List<PetParaAdocao>> Function()? loadPets;

  const PetsPage({super.key, this.loadPets});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  late Future<List<PetParaAdocao>> _petsFuture;

  @override
  void initState() {
    super.initState();
    // Se não passar nada, usamos o loader padrão que chama a API
    _petsFuture = (widget.loadPets ?? _carregarPetsPadrao)();
  }

  /// Carrega da API (JSON) e converte para List<PetParaAdocao>
  Future<List<PetParaAdocao>> _carregarPetsPadrao() async {
    final listaJson = await PetService.getPets(); // ainda retorna List<dynamic>

    return listaJson.map<PetParaAdocao>((json) {
      return PetParaAdocao(
        id: json['id'] as int?,
        nome: json['nome'] ?? '',
        descricao: json['descricao'] ?? '',
        especie: json['especie'] ?? '',
        raca: json['raca'] ?? '',
        idade: json['idade'] ?? '',
        bairro: json['bairro'] ?? '',
        cidade: json['cidade'] ?? '',
        estado: json['estado'] ?? '',
        imagemPath:
            (json['foto'] != null && (json['foto'] as String).isNotEmpty)
            ? '${PetService.baseUrl}${json['foto']}'
            : 'assets/images/tom.png',
        telefoneTutor: json['telefoneTutor'] ?? '',
      );
    }).toList();
  }

  Widget _buildCircleImage(PetParaAdocao pet) {
    final path = pet.imagemPath;

    // URL (vindo da API)
    if (path.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          path,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
          errorBuilder: (_, __, ___) => const Icon(Icons.pets),
        ),
      );
    }

    // Arquivo local
    if (path.startsWith('/') || path.contains('storage')) {
      return ClipOval(
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          width: 40,
          height: 40,
          errorBuilder: (_, __, ___) => const Icon(Icons.pets),
        ),
      );
    }

    // Asset
    return ClipOval(
      child: Image.asset(path, fit: BoxFit.cover, width: 40, height: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pets para adoção")),
      body: FutureBuilder<List<PetParaAdocao>>(
        future: _petsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Erro ao carregar pets. Tente novamente mais tarde.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final pets = snapshot.data;

          if (pets == null || pets.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum pet disponível para adoção no momento.",
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];

              return ListTile(
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE7EBF7),
                  child: _buildCircleImage(pet),
                ),
                title: Text(pet.nome),
                subtitle: Text(
                  pet.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
