import 'package:flutter/material.dart';
import 'package:miaudota_app/services/pet_service.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  late Future<List<dynamic>> petsFuture;

  @override
  void initState() {
    super.initState();
    petsFuture = PetService.getPets(); // Chama a API quando a tela abre
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pets para adoção")),
      body: FutureBuilder<List<dynamic>>(
        future: petsFuture,
        builder: (context, snapshot) {
          // Carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Erro real (API caiu, sem internet etc.)
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Erro ao carregar pets. Tente novamente mais tarde.",
                textAlign: TextAlign.center,
              ),
            );
          }

          // Nenhum dado retornado (por segurança)
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "Nenhum pet disponível no momento.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final pets = snapshot.data!;

          // ✅ Lista vazia → mensagem amigável, não erro
          if (pets.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum pet disponível para adoção no momento.",
                textAlign: TextAlign.center,
              ),
            );
          }

          // Lista com pets → mostra normalmente
          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];

              final foto = (pet['foto'] ?? '').toString();

              return ListTile(
                leading: CircleAvatar(
                  child: foto.isEmpty
                      ? const Icon(Icons.pets)
                      : ClipOval(
                          child: Image.network(
                            foto,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.pets);
                            },
                          ),
                        ),
                ),
                title: Text(pet['nome'] ?? 'Pet sem nome'),
                subtitle: Text(
                  pet['descricao'] ?? '',
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
