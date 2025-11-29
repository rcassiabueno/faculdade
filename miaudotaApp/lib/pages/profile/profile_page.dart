import 'package:flutter/material.dart';
import 'package:miaudota_app/main.dart';
import 'package:miaudota_app/theme/colors.dart';
import 'package:miaudota_app/components/miaudota_bottom_nav.dart';
import 'edit_profile_page.dart';
import 'package:miaudota_app/pets/pet_form_page.dart';
import 'package:miaudota_app/components/miaudota_top_bar.dart';
import 'package:miaudota_app/splash_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miaudota_app/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  void _abrirSolicitacoesParaPet(PetParaAdocao pet) {
    final pendentes = AppState.solicitacoesPendentes
        .where((s) => s.pet.nome == pet.nome && !s.aprovado)
        .toList();

    if (pendentes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há solicitações de adoção para este pet.'),
        ),
      );
      return;
    }

    final solicitacao = pendentes.first;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Solicitação de adoção',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            '${solicitacao.nomeInteressado} quer adotar ${solicitacao.pet.nome}.',
            textAlign: TextAlign.center,
          ),
          actionsPadding: const EdgeInsets.only(
            bottom: 12,
            right: 12,
            left: 12,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE5E5),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _recusarSolicitacao(solicitacao);
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Recusar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _aprovarSolicitacao(solicitacao);
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Aprovar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _recusarSolicitacao(SolicitacaoAdocao s) {
    final index = AppState.petsAdotados.indexWhere((p) => p.nome == s.pet.nome);

    if (index != -1) {
      AppState.petsAdotados[index].aprovado = false;
      AppState.petsAdotados[index].reprovado = true;
    }

    AppState.solicitacoesPendentes.remove(s);
    setState(() {});
  }

  void _aprovarSolicitacao(SolicitacaoAdocao s) {
    s.aprovado = true;

    AppState.petsParaAdocao.removeWhere((p) => p.nome == s.pet.nome);

    final adotado = AppState.petsAdotados.firstWhere(
      (p) => p.nome == s.pet.nome,
      orElse: () {
        final novo = PetAdotado(
          nome: s.pet.nome,
          tipo: s.pet.tipo,
          aprovado: true,
          reprovado: false,
        );
        AppState.petsAdotados.add(novo);
        return novo;
      },
    );

    adotado.aprovado = true;
    adotado.reprovado = false;

    AppState.solicitacoesPendentes.remove(s);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppState.userProfile;

    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            const MiaudotaTopBar(titulo: 'Meu perfil', showBackButton: false),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // CARD DADOS DA PESSOA
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 28,
                                backgroundColor: Color(0xFFFFE0B5),
                                child: Icon(
                                  Icons.person,
                                  color: primaryOrange,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  profile.nome.isEmpty
                                      ? 'Seu nome'
                                      : profile.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Color(0xFF1D274A),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 22),
                                color: const Color(0xFF1D274A),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfilePage(),
                                    ),
                                  );
                                  setState(() {});
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // CPF ou CNPJ / Email / Telefone / Estado / Cidade / Bairro
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                TextSpan(
                                  text: profile.isPessoaJuridica
                                      ? 'CNPJ\n'
                                      : 'CPF\n',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: profile.isPessoaJuridica
                                      ? (profile.cnpj.isEmpty
                                            ? '—'
                                            : profile.cnpj)
                                      : (profile.cpf.isEmpty
                                            ? '—'
                                            : profile.cpf),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'E-mail\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: profile.email.isEmpty
                                      ? '—'
                                      : profile.email,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Telefone\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: profile.telefone.isEmpty
                                      ? '—'
                                      : profile.telefone,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Estado\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: profile.estado.isEmpty
                                      ? '—'
                                      : profile.estado,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Cidade\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: profile.cidade.isEmpty
                                      ? '—'
                                      : profile.cidade,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Bairro\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: profile.bairro.isEmpty
                                      ? '—'
                                      : profile.bairro,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // PETS QUE ADOTOU
                    Row(
                      children: const [
                        Icon(Icons.favorite, color: primaryOrange),
                        SizedBox(width: 8),
                        Text(
                          'Pets que adotou',
                          style: TextStyle(
                            fontFamily: 'PoetsenOne',
                            fontSize: 16,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (AppState.petsAdotados.isEmpty)
                      const Text(
                        'Você ainda não adotou nenhum pet.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777),
                        ),
                      )
                    else
                      Column(
                        children: AppState.petsAdotados.map((pet) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.nome,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: Color(0xFF1D274A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        pet.tipo,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        pet.reprovado
                                            ? 'Adoção reprovada'
                                            : (pet.aprovado
                                                  ? 'Adoção aprovada'
                                                  : 'Aguardando aprovação'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: pet.reprovado
                                              ? Colors.red
                                              : (pet.aprovado
                                                    ? Colors.green
                                                    : const Color.fromARGB(
                                                        255,
                                                        255,
                                                        138,
                                                        60,
                                                      )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!pet.aprovado)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        AppState.petsAdotados.remove(pet);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                Icon(
                                  Icons.favorite,
                                  color: pet.aprovado
                                      ? primaryOrange
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 24),

                    // PETS PARA ADOÇÃO
                    Row(
                      children: const [
                        Icon(Icons.pets, color: primaryOrange),
                        SizedBox(width: 8),
                        Text(
                          'Pets para adoção',
                          style: TextStyle(
                            fontFamily: 'PoetsenOne',
                            fontSize: 16,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (AppState.petsParaAdocao.isEmpty)
                      const Text(
                        'Você ainda não adicionou nenhum pet para adoção.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777),
                        ),
                      )
                    else
                      Column(
                        children: AppState.petsParaAdocao.map((pet) {
                          final pendentesDoPet = AppState.solicitacoesPendentes
                              .where(
                                (s) => s.pet.nome == pet.nome && !s.aprovado,
                              )
                              .toList();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.nome,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF1D274A),
                                        ),
                                      ),
                                      Text(
                                        pet.tipo,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF777777),
                                        ),
                                      ),
                                      if (pendentesDoPet.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          '${pendentesDoPet.length} solicitação(ões) pendente(s)',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                if (pendentesDoPet.isEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: Color(0xFF1D274A),
                                        ),
                                        onPressed: () async {
                                          final updated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PetFormPage(pet: pet),
                                            ),
                                          );

                                          if (updated == true) {
                                            setState(
                                              () {},
                                            ); // atualiza a tela com os dados editados
                                          }
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            AppState.petsParaAdocao.remove(pet);
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  TextButton(
                                    onPressed: () {
                                      _abrirSolicitacoesParaPet(pet);
                                    },
                                    child: const Text(
                                      'Ver solicitações',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primaryOrange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    TextButton.icon(
                      onPressed: () async {
                        if (!isUserProfileComplete()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFF1D274A),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                              content: Text(
                                'Complete seus dados de perfil (nome, CPF/CNPJ, e-mail, telefone, cidade, estado e bairro) antes de cadastrar um pet para adoção.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              duration: Duration(seconds: 4),
                            ),
                          );

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          );

                          setState(
                            () {},
                          ); // atualiza depois que voltar do editar perfil
                          return;
                        }

                        // se cadastro está completo, segue para a tela de cadastro de pet
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PetFormPage(),
                          ),
                        );
                        setState(() {});
                      },
                      icon: const Icon(Icons.add, color: primaryOrange),
                      label: const Text(
                        'Adicionar novo pet para adoção',
                        style: TextStyle(color: primaryOrange),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SAIR DA CONTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEEEEE),
                          foregroundColor: const Color(0xFF1D274A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          await AuthService.logout();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('user_id');

                          AppState.userProfile = UserProfile(
                            nome: '',
                            cpf: '',
                            cnpj: '',
                            isPessoaJuridica: false,
                            email: '',
                            telefone: '',
                            estado: '',
                            cidade: '',
                            bairro: '',
                          );
                          AppState.petsAdotados.clear();
                          AppState.petsParaAdocao.clear();
                          AppState.solicitacoesPendentes.clear();

                          // Volta para tela inicial
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SplashRouter(),
                            ),
                            (route) => false,
                          );
                        },

                        child: const Text(
                          'Sair da conta',
                          style: TextStyle(
                            fontFamily: 'PoetsenOne',
                            fontSize: 16,
                            color: Color(0xFF1D274A),
                          ),
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
      bottomNavigationBar: const MiaudotaBottomNav(currentIndex: 3),
    );
  }
}
