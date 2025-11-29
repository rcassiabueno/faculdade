import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:miaudota_app/main.dart';
import 'package:miaudota_app/components/miaudota_bottom_nav.dart';
import 'package:miaudota_app/theme/colors.dart';
import 'package:miaudota_app/components/miaudota_top_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdoptionPage extends StatefulWidget {
  final PetParaAdocao pet;

  const AdoptionPage({super.key, required this.pet});

  @override
  State<AdoptionPage> createState() => _AdoptionPageState();
}

class _AdoptionPageState extends State<AdoptionPage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();

    // Descobre em qual posição da lista está o pet recebido
    final i = AppState.petsParaAdocao.indexWhere(
      (p) => p.nome == widget.pet.nome,
    );

    _index = i == -1 ? 0 : i;
  }

  Widget _buildPetImage(PetParaAdocao pet) {
    final path = pet.imagemPath;

    // Se for URL (foto vindo da API)
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        height: 450,
        errorBuilder: (ctx, error, stack) =>
            const Center(child: Text('Imagem indisponível')),
      );
    }

    // Se for arquivo local (galeria / armazenamento)
    if (path.startsWith('/') || path.contains('storage')) {
      return Image.file(File(path), fit: BoxFit.cover, height: 450);
    }

    // Caso contrário, assume que é asset
    return Image.asset(path, fit: BoxFit.cover, height: 450);
  }

  Future<void> _abrirWhatsApp(
    BuildContext context, {
    required String numeroComDDD,
    required String mensagem,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final url = Uri.parse(
      'https://wa.me/$numeroComDDD?text=${Uri.encodeComponent(mensagem)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1D274A),
          content: const Text(
            'Não foi possível abrir o WhatsApp. Tente novamente mais tarde.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppState.petsParaAdocao.isEmpty) {
      return Scaffold(
        backgroundColor: lightBeige,
        body: const Center(
          child: Text('Nenhum pet disponível para adoção no momento.'),
        ),
      );
    }

    final pet = AppState.petsParaAdocao[_index];

    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            const MiaudotaTopBar(titulo: 'Adoção', showBackButton: false),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Imagem do pet
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            child: _buildPetImage(pet),
                          ),

                          const SizedBox(height: 12),

                          // Nome do pet
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              pet.nome,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D274A),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Exemplo de descrição (ajuste conforme os campos que você tiver no modelo)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Esse é um pet muito especial aguardando uma família cheia de amor. '
                              'Entre em contato para saber mais detalhes sobre o histórico, cuidados e perfil ideal de tutor.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Botão de contato via WhatsApp
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _abrirWhatsApp(
                                    context,
                                    numeroComDDD: pet.telefoneTutor,
                                    mensagem:
                                        'Olá! Tenho interesse em adotar o ${pet.nome}.',
                                  );
                                },
                                icon: const FaIcon(FontAwesomeIcons.whatsapp),
                                label: const Text(
                                  'Quero adotar',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1D274A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        '${_index + 1} de ${AppState.petsParaAdocao.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const MiaudotaBottomNav(currentIndex: 0),
    );
  }
}
