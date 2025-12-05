import 'dart:io';
import 'package:flutter/material.dart';
import 'package:miaudota_app/main.dart';
import 'package:miaudota_app/services/pet_service.dart';
import 'package:miaudota_app/utils/snackbar_utils.dart';
import 'adoption_page.dart';
import 'package:miaudota_app/components/miaudota_bottom_nav.dart';
import 'package:miaudota_app/theme/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _petIndex = 0;
  List<PetParaAdocao> _petsFiltrados = [];
  bool _carregando = false;

  String? _filtroEspecie;
  String? _filtroRaca;
  String? _filtroCidade;
  String? _filtroEstado;

  final TextEditingController _filtroEspecieController =
      TextEditingController();
  final TextEditingController _filtroRacaController = TextEditingController();
  final TextEditingController _filtroCidadeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarPetsDaApi();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarSolicitacoesPendentes();
    });
  }

  @override
  void dispose() {
    _filtroEspecieController.dispose();
    _filtroRacaController.dispose();
    _filtroCidadeController.dispose();
    super.dispose();
  }

  Future<void> _carregarPetsDaApi() async {
    setState(() => _carregando = true);

    try {
      final listaJson = await PetService.getPets();

      final petsDaApi = listaJson.map<PetParaAdocao>((json) {
        final foto = json['foto'] as String?;

        return PetParaAdocao(
          id: (json['id'] as num?)?.toInt(),
          nome: json['nome'] ?? '',
          descricao: json['descricao'] ?? '',
          especie: json['especie'] ?? '',
          tipo: json['especie'] ?? '', // 👈 usando especie como tipo
          raca: json['raca'] ?? '',
          idade: json['idade'] ?? '',
          bairro: json['bairro'] ?? '',
          cidade: json['cidade'] ?? '',
          estado: json['estado'] ?? '',
          imagemPath: (foto != null && foto.isNotEmpty)
              ? '${PetService.baseUrl}$foto'
              : 'assets/images/tom.png',
          telefoneTutor: json['telefoneTutor'] ?? '',
          usuarioId: json['usuario_id'] != null
              ? (json['usuario_id'] as num).toInt()
              : null,
        );
      }).toList();

      AppState.petsParaAdocao
        ..clear()
        ..addAll(petsDaApi);

      setState(() {
        _petsFiltrados = List.from(AppState.petsParaAdocao);
        _petIndex = 0;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      SnackbarUtils.showError(context, 'Erro ao carregar pets da API: $e');
    }
  }

  InputDecoration _filtroDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(color: Color(0xFF777777), fontSize: 14),
      floatingLabelStyle: const TextStyle(
        color: primaryOrange,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 1.6),
      ),
    );
  }

  void _verificarSolicitacoesPendentes() {
    // dono do pet = telefone salvo no perfil
    final profile = AppState.userProfile;
    final meuTelefone = profile.telefone.trim();

    if (meuTelefone.isEmpty) {
      return; // sem telefone no perfil, não tem como saber quem é tutor
    }

    // só as solicitações dos meus pets
    final minhasSolicitacoes = AppState.solicitacoesPendentes
        .where(
          (s) =>
              s.pet.telefoneTutor.trim() == meuTelefone &&
              !s.aprovado, // ainda não tratadas
        )
        .toList();

    if (minhasSolicitacoes.isEmpty) return;

    final solicitacao = minhasSolicitacoes.first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Center(
          child: Text(
            'Nova solicitação de adoção',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        content: Text(
          '${solicitacao.nomeInteressado} quer adotar ${solicitacao.pet.nome}.',
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8, top: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFFE5E5),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              AppState.solicitacoesPendentes.remove(solicitacao);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text(
              'Recusar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              solicitacao.aprovado = true;

              // remove pet da lista de disponíveis
              AppState.petsParaAdocao.removeWhere(
                (p) => p.nome == solicitacao.pet.nome,
              );

              // marca como aprovado em petsAdotados (se já existir lá)
              for (final p in AppState.petsAdotados) {
                if (p.nome == solicitacao.pet.nome) {
                  p.aprovado = true;
                }
              }

              AppState.solicitacoesPendentes.remove(solicitacao);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text(
              'Aprovar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _aplicarFiltros() {
    setState(() {
      _petsFiltrados = AppState.petsParaAdocao.where((pet) {
        final matchEspecie =
            _filtroEspecie == null ||
            _filtroEspecie!.isEmpty ||
            pet.especie.toLowerCase().contains(_filtroEspecie!.toLowerCase());

        final matchRaca =
            _filtroRaca == null ||
            _filtroRaca!.isEmpty ||
            pet.raca.toLowerCase().contains(_filtroRaca!.toLowerCase());

        final matchCidade =
            _filtroCidade == null ||
            _filtroCidade!.isEmpty ||
            pet.cidade.toLowerCase().contains(_filtroCidade!.toLowerCase());

        final matchEstado =
            _filtroEstado == null ||
            _filtroEstado!.isEmpty ||
            pet.estado.toLowerCase() == _filtroEstado!.toLowerCase();

        return matchEspecie && matchRaca && matchCidade && matchEstado;
      }).toList();

      _petIndex = 0;
    });
  }

  void _abrirFiltros() {
    _filtroEspecieController.text = _filtroEspecie ?? '';
    _filtroRacaController.text = _filtroRaca ?? '';
    _filtroCidadeController.text = _filtroCidade ?? '';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          insetPadding: const EdgeInsets.fromLTRB(16, 60, 16, 220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Filtros de busca',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PoetsenOne',
              fontSize: 16,
              color: Color(0xFF1D274A),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Refine a busca pelos pets disponíveis para adoção:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF777777)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _filtroEspecieController,
                  decoration: _filtroDecoration('Espécie (ex: Gato, Cachorro)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _filtroRacaController,
                  decoration: _filtroDecoration('Raça (ex: SRD, Siamês)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _filtroCidadeController,
                  decoration: _filtroDecoration('Cidade'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _filtroEstado,
                  decoration: _filtroDecoration('Estado'),
                  items: estadosBrasil
                      .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _filtroEstado = value);
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _filtroEspecieController.clear();
                        _filtroRacaController.clear();
                        _filtroCidadeController.clear();
                        _filtroEspecie = '';
                        _filtroRaca = '';
                        _filtroCidade = '';
                        _filtroEstado = null;
                        _aplicarFiltros();
                      });
                      Navigator.pop(ctx);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9F9F9),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Limpar filtros',
                      style: TextStyle(color: Color(0xFF1D274A)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filtroEspecie = _filtroEspecieController.text.trim();
                        _filtroRaca = _filtroRacaController.text.trim();
                        _filtroCidade = _filtroCidadeController.text.trim();
                        _aplicarFiltros();
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPetImage(PetParaAdocao pet) {
    final path = pet.imagemPath;

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        height: 450,
        errorBuilder: (ctx, error, stack) =>
            const Center(child: Text('Imagem indisponível')),
      );
    }

    if (path.startsWith('/') || path.contains('storage')) {
      return Image.file(File(path), fit: BoxFit.cover, height: 450);
    }

    return Image.asset(path, fit: BoxFit.cover, height: 450);
  }

  @override
  Widget build(BuildContext context) {
    final pet = _petsFiltrados.isNotEmpty ? _petsFiltrados[_petIndex] : null;

    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: const Color(0xFFFFE0B5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo.png', height: 64),
                  OutlinedButton.icon(
                    onPressed: _abrirFiltros,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryOrange),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(
                      Icons.tune,
                      size: 16,
                      color: primaryOrange,
                    ),
                    label: const Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _petsFiltrados.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Nenhum pet encontrado com os filtros atuais.\n\n'
                          'Ajuste os filtros para ver outros pets disponíveis 🐾',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                  child: _buildPetImage(pet!),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 42,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            pet.nome,
                                            style: const TextStyle(
                                              fontFamily: 'PoetsenOne',
                                              fontSize: 20,
                                              color: Color(0xFF1D274A),
                                            ),
                                          ),
                                          Text(
                                            '${pet.cidade} – ${pet.estado}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: Color(0xFF1D274A),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${pet.especie} • ${pet.idade}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _petIndex++;
                                                  if (_petIndex >=
                                                      _petsFiltrados.length) {
                                                    _petIndex = 0;
                                                  }
                                                });
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Color(0xFFCCCCCC),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                backgroundColor: const Color(
                                                  0xFFF9F9F9,
                                                ),
                                              ),
                                              child: const Text(
                                                'Próximo',
                                                style: TextStyle(
                                                  fontFamily: 'PoetsenOne',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  color: Color(0xFF1D274A),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        AdoptionPage(pet: pet),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryOrange,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'Ver detalhes',
                                                style: TextStyle(
                                                  fontFamily: 'PoetsenOne',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_petIndex + 1} de ${_petsFiltrados.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
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
