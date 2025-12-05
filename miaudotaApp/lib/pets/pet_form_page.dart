import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miaudota_app/theme/colors.dart';
import 'package:miaudota_app/main.dart';
import 'package:miaudota_app/services/pet_service.dart';
import 'package:miaudota_app/components/miaudota_bottom_nav.dart';
import 'package:miaudota_app/components/miaudota_top_bar.dart';
import 'package:miaudota_app/main.dart'
    show estadosBrasil, AppState, isUserProfileComplete, PetParaAdocao;
import 'package:miaudota_app/services/auth_service.dart';

int? _parseUsuarioId(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is String) return int.tryParse(raw);
  return null;
}

class PetFormPage extends StatefulWidget {
  final PetParaAdocao? pet; // null = novo, != null = editar

  const PetFormPage({super.key, this.pet});

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _especieController;
  late TextEditingController _racaController;
  late TextEditingController _idadeController;
  late TextEditingController _descricaoController;
  late TextEditingController _imagemController;
  late TextEditingController _cidadeController;
  late TextEditingController _bairroController;
  String? _estadoSelecionado;

  final ImagePicker _picker = ImagePicker();
  XFile? _imagemSelecionada; // foto escolhida pelo usuário

  @override
  void initState() {
    super.initState();

    final p = widget.pet;

    if (p != null) {
      // EDITAR PET
      _nomeController = TextEditingController(text: p.nome);
      _especieController = TextEditingController(text: p.especie);
      _racaController = TextEditingController(text: p.raca);
      _idadeController = TextEditingController(text: p.idade);
      _descricaoController = TextEditingController(text: p.descricao);
      _imagemController = TextEditingController(text: p.imagemPath);
      _cidadeController = TextEditingController(text: p.cidade);
      _bairroController = TextEditingController(text: p.bairro);
      _estadoSelecionado = p.estado;
    } else {
      // NOVO PET: começa com dados do perfil
      final profile = AppState.userProfile;

      _nomeController = TextEditingController();
      _especieController = TextEditingController();
      _racaController = TextEditingController();
      _idadeController = TextEditingController();
      _descricaoController = TextEditingController();
      _imagemController = TextEditingController();
      _cidadeController = TextEditingController(text: profile.cidade);
      _bairroController = TextEditingController(text: profile.bairro);
      _estadoSelecionado = profile.estado.isNotEmpty ? profile.estado : null;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _especieController.dispose();
    _racaController.dispose();
    _idadeController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    _descricaoController.dispose();
    _imagemController.dispose();
    super.dispose();
  }

  // mesma ideia dos outros campos: label cinza; laranja só focado
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          color: _labelColor(states),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!isUserProfileComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete seu cadastro antes de salvar um pet para adoção.',
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.pet != null;

    final imagemPath = _imagemController.text.trim();
    final temFotoAntiga = imagemPath.isNotEmpty;
    final temFotoNovaArquivo = _imagemSelecionada != null;
    final bool isLink =
        imagemPath.startsWith('http://') || imagemPath.startsWith('https://');

    // Novo pet: exige foto por arquivo OU link
    if (!isEdit && !temFotoNovaArquivo && !temFotoAntiga) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Adicione uma foto do pet (arquivo ou link)."),
        ),
      );
      return;
    }

    // Editar pet: exige foto só se não tiver nem antiga nem nova
    if (isEdit && !temFotoNovaArquivo && !temFotoAntiga) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Adicione uma foto do pet (arquivo ou link)."),
        ),
      );
      return;
    }

    final perfil = AppState.userProfile;

    try {
      final userIdStr = await AuthService.getUserId();
      final userId = userIdStr != null ? int.tryParse(userIdStr) : null;

      Map<String, dynamic> petJson;

      if (isEdit && widget.pet?.id != null) {
        // 🔁 ATUALIZAR (vou deixar igual por enquanto, usando só fotoFile)
        petJson = await PetService.updatePet(
          id: widget.pet!.id!,
          nome: _nomeController.text.trim(),
          especie: _especieController.text.trim(),
          raca: _racaController.text.trim(),
          idade: _idadeController.text.trim(),
          descricao: _descricaoController.text.trim(),
          cidade: _cidadeController.text.trim(),
          estado: _estadoSelecionado ?? '',
          bairro: _bairroController.text.trim(),
          telefoneTutor: perfil.telefone,
          fotoFile: _imagemSelecionada != null
              ? File(_imagemSelecionada!.path)
              : null,
        );

        // ... (resto igual)
      } else {
        // ✨ CRIAR
        petJson = await PetService.createPet(
          nome: _nomeController.text.trim(),
          especie: _especieController.text.trim(),
          raca: _racaController.text.trim(),
          idade: _idadeController.text.trim(),
          descricao: _descricaoController.text.trim(),
          cidade: _cidadeController.text.trim(),
          estado: _estadoSelecionado ?? '',
          bairro: _bairroController.text.trim(),
          telefoneTutor: perfil.telefone,
          fotoFile: (!isLink && _imagemSelecionada != null)
              ? File(_imagemSelecionada!.path)
              : null,
          fotoUrl: isLink ? imagemPath : null, // 👈 NOVO
          usuarioId: userId,
        );

        AppState.petsParaAdocao.add(
          PetParaAdocao(
            id: petJson['id'],
            nome: petJson['nome'],
            especie: petJson['especie'],
            tipo: petJson['especie'], // 👈 CORREÇÃO OBRIGATÓRIA AQUI
            raca: petJson['raca'],
            idade: petJson['idade'],
            descricao: petJson['descricao'],
            cidade: petJson['cidade'],
            estado: petJson['estado'],
            bairro: petJson['bairro'],

            imagemPath: (petJson['foto'] != null)
                ? '${PetService.baseUrl}${petJson['foto']}'
                : 'assets/images/tom.png',

            telefoneTutor: petJson['telefoneTutor'],

            usuarioId: _parseUsuarioId(petJson['usuario_id']),
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar pet: $e')));
    }
  }

  Color _labelColor(Set<WidgetState> states) {
    if (states.contains(WidgetState.focused)) {
      return primaryOrange; // foca → laranja
    }
    return const Color(0xFF777777); // desfocou → cinza
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.pet != null;

    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            MiaudotaTopBar(
              titulo: isEdit ? 'Editar pet' : 'Cadastrar pet',
              showBackButton: true,
            ),

            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isEdit
                              ? 'Atualize as informações do pet:'
                              : 'Preencha os dados do pet para disponibilizá-lo para adoção:',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF777777),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Campo de foto
                        GestureDetector(
                          onTap: () async {
                            final picked = await _picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 1024,
                              maxHeight: 1024,
                              imageQuality: 85,
                            );

                            if (picked != null) {
                              setState(() {
                                _imagemSelecionada = picked;
                                _imagemController.text = picked.path;
                              });
                            }
                          },
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                            child: _buildImagePreview(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ⬇️ NOVO: campo para link da foto
                        TextFormField(
                          controller: _imagemController,
                          keyboardType: TextInputType.url,
                          decoration: _inputDecoration(
                            'Link da foto (opcional)',
                          ),
                          onChanged: (value) {
                            // se a pessoa digitar link, limpamos a imagem escolhida da galeria
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                _imagemSelecionada = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // NOME
                        TextFormField(
                          controller: _nomeController,
                          decoration: _inputDecoration(
                            'Nome do pet* (ex: Tom)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome do pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // ESPÉCIE
                        TextFormField(
                          controller: _especieController,
                          decoration: _inputDecoration(
                            'Espécie* (ex: Gato, Cachorro)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a espécie do pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // RAÇA
                        TextFormField(
                          controller: _racaController,
                          decoration: _inputDecoration(
                            'Raça* (ex: SRD, Siamês)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a raça do pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // IDADE
                        TextFormField(
                          controller: _idadeController,
                          decoration: _inputDecoration(
                            'Idade* (ex: 2 anos, 4 meses)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a idade do pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // BAIRRO
                        TextFormField(
                          controller: _bairroController,
                          decoration: _inputDecoration('Bairro do pet*'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o bairro do pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // CIDADE
                        TextFormField(
                          controller: _cidadeController,
                          decoration: _inputDecoration('Cidade do pet*'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a cidade do pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        DropdownButtonFormField<String>(
                          initialValue: _estadoSelecionado,
                          decoration: _inputDecoration('Estado do pet*'),
                          items: estadosBrasil.map((uf) {
                            return DropdownMenuItem(value: uf, child: Text(uf));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _estadoSelecionado = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione o estado do pet';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // DESCRIÇÃO
                        TextFormField(
                          controller: _descricaoController,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            'Descrição do pet* (temperamento, cuidados, etc.)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Descreva um pouco sobre o pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // BOTÕES
                        Row(
                          children: [
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
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: const Color(0xFFF9F9F9),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontFamily: 'PoetsenOne',
                                    fontSize: 16,
                                    color: Color(0xFF1D274A),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _salvar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryOrange,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Salvar',
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
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MiaudotaBottomNav(currentIndex: 3),
    );
  }

  /// Decide qual imagem mostrar no card (galeria, caminho manual ou placeholder)
  Widget _buildImagePreview() {
    // 1) Se escolheu pela galeria
    if (_imagemSelecionada != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(_imagemSelecionada!.path),
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }

    final path = _imagemController.text.trim();

    // 2) Se tem algo preenchido no campo de imagem/link
    if (path.isNotEmpty) {
      final isLinkHttp =
          path.startsWith('http://') || path.startsWith('https://');

      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: isLinkHttp
            ? Image.network(
                path,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Não foi possível carregar a imagem.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                  );
                },
              )
            : Image.file(File(path), fit: BoxFit.cover, width: double.infinity),
      );
    }

    // 3) Senão, mostra placeholder
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.photo_camera_outlined, size: 32, color: Color(0xFFB3B3B3)),
        SizedBox(height: 8),
        Text(
          'Adicionar foto',
          style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
        ),
      ],
    );
  }
}
