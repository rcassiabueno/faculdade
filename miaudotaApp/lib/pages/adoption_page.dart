import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:miaudota_app/main.dart';
import 'package:miaudota_app/components/miaudota_bottom_nav.dart';
import 'package:miaudota_app/components/miaudota_top_bar.dart';
import 'package:miaudota_app/theme/colors.dart';

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

  void _criarSolicitacaoAdocao(PetParaAdocao pet) {
    final perfil = AppState.userProfile;

    final nomeInteressado = perfil.nome.trim().isNotEmpty
        ? perfil.nome.trim()
        : 'Tutor interessado';

    final emailInteressado = perfil.email.trim().isNotEmpty
        ? perfil.email.trim()
        : 'sem-email@exemplo.com';

    final telefoneInteressado = perfil.telefone.trim();

    // Evita duplicar solicitação igual para o mesmo pet e mesma pessoa
    final jaTemSolic = AppState.solicitacoesPendentes.any(
      (s) =>
          s.pet.nome == pet.nome &&
          !s.aprovado &&
          s.nomeInteressado == nomeInteressado &&
          s.emailInteressado == emailInteressado &&
          s.telefoneInteressado == telefoneInteressado,
    );

    if (!jaTemSolic) {
      AppState.solicitacoesPendentes.add(
        SolicitacaoAdocao(
          pet: pet,
          nomeInteressado: nomeInteressado,
          emailInteressado: emailInteressado,
          telefoneInteressado: telefoneInteressado,
        ),
      );
    }

    // Garante que apareça em "Pets que adotou"
    final jaTemPetAdotado = AppState.petsAdotados.any(
      (p) => p.nome == pet.nome,
    );

    if (!jaTemPetAdotado) {
      AppState.petsAdotados.add(
        PetAdotado(
          nome: pet.nome,
          tipo: pet.tipo, // ou pet.especie, se for assim na sua classe
          aprovado: false,
          reprovado: false,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Solicitação de adoção enviada! Aguarde a aprovação do tutor.',
        ),
      ),
    );
  }

  Widget _buildPetImage(String path) {
    const double imageHeight = 450;

    if (path.isEmpty) {
      return const SizedBox(
        height: imageHeight,
        child: Center(child: Text('Imagem não disponível')),
      );
    }

    // Se for URL (foto vindo da API)
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        height: imageHeight,
        errorBuilder: (ctx, error, stack) => const SizedBox(
          height: imageHeight,
          child: Center(child: Text('Imagem indisponível')),
        ),
      );
    }

    // Se for arquivo local (galeria / armazenamento)
    if (path.startsWith('/') || path.contains('storage')) {
      return Image.file(File(path), fit: BoxFit.cover, height: imageHeight);
    }

    // Caso contrário, assume que é asset
    return Image.asset(path, fit: BoxFit.cover, height: imageHeight);
  }

  @override
  Widget build(BuildContext context) {
    if (AppState.petsParaAdocao.isEmpty) {
      return const Scaffold(
        backgroundColor: lightBeige,
        body: Center(
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
                            child: _buildPetImage(pet.imagemPath),
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

                          // Dados do pet (espécie, raça, idade, localização)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${pet.especie} • ${pet.raca}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF555555),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (pet.idade.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Idade: ${pet.idade}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF555555),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Localização: ${pet.bairro}, ${pet.cidade} - ${pet.estado}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Descrição do pet (se houver) ou texto guia
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              (pet.descricao.isNotEmpty)
                                  ? pet.descricao
                                  : 'Esse é um pet muito especial aguardando uma família cheia de amor. '
                                        'Entre em contato para saber mais detalhes sobre o histórico, cuidados '
                                        'e perfil ideal de tutor.',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Botões: Cancelar + Quero adotar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                // Botão Cancelar
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFCCCCCC),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: const Color(0xFFF9F9F9),
                                    ),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF1D274A),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Botão WhatsApp - Quero adotar
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // 1) cria a solicitação e popula "Pets que adotou"
                                      _criarSolicitacaoAdocao(pet);

                                      // 2) mantém o comportamento de abrir o WhatsApp
                                      abrirWhatsApp(
                                        context,
                                        numeroComDDD: pet.telefoneTutor,
                                        mensagem:
                                            'Olá! Tenho interesse em adotar o ${pet.nome}.',
                                      );
                                    },
                                    icon: const FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Quero adotar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
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
                              ],
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
      bottomNavigationBar: const MiaudotaBottomNav(currentIndex: 1),
    );
  }
}
