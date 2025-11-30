import 'package:flutter/material.dart';
import 'package:miaudota_app/services/pet_service.dart';

class PetsPage extends StatefulWidget {
  final Future<List<dynamic>> Function()? loadPets;

  const PetsPage({super.key, this.loadPets});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  late Future<List<dynamic>> petsFuture;

  @override
  void initState() {
    super.initState();
    petsFuture = (widget.loadPets ?? PetService.getPets)();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pets para adoção")),
      body: FutureBuilder<List<dynamic>>(
        future: petsFuture,
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

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "Nenhum pet disponível no momento.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final pets = snapshot.data!;

          if (pets.isEmpty) {
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
