import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:miaudota_app/main.dart';
import 'package:miaudota_app/theme/colors.dart';
import 'package:miaudota_app/login_page.dart';
import 'package:miaudota_app/components/miaudota_bottom_nav.dart';
import 'package:miaudota_app/components/miaudota_top_bar.dart';
import 'package:miaudota_app/services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  final Future<String?> Function()? getUserIdAction;

  final Future<void> Function({
    required String userId,
    required String nome,
    required String cpf,
    required String telefone,
    required String cidade,
    required String estado,
    required String bairro,
    String? cnpj,
    bool isPessoaJuridica,
  })?
  updateProfileAction;

  final Future<void> Function(String userId)? deleteAccountAction;
  final Future<void> Function()? logoutAction;

  const EditProfilePage({
    super.key,
    this.getUserIdAction,
    this.updateProfileAction,
    this.deleteAccountAction,
    this.logoutAction,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _cpfController;
  late TextEditingController _cnpjController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _cidadeController;
  late TextEditingController _bairroController;

  String? _estadoSelecionado;
  bool _isPessoaJuridica = false;

  @override
  void initState() {
    super.initState();
    final p = AppState.userProfile;

    _nomeController = TextEditingController(text: p.nome);
    _cpfController = TextEditingController(text: p.cpf);
    _cnpjController = TextEditingController(text: p.cnpj);
    _emailController = TextEditingController(text: p.email);
    _telefoneController = TextEditingController(text: p.telefone);
    _cidadeController = TextEditingController(text: p.cidade);
    _bairroController = TextEditingController(text: p.bairro);

    _estadoSelecionado = p.estado.isNotEmpty ? p.estado : null;
    _isPessoaJuridica = p.isPessoaJuridica;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 1.4),
      ),
      labelStyle: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 14),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          color: _labelColor(states),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
      );
      return;
    }

    final getUserId = widget.getUserIdAction ?? AuthService.getUserId;
    final updateProfile =
        widget.updateProfileAction ?? AuthService.updateProfile;

    final userId = await getUserId();
    if (!mounted) return;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado (ID ausente).')),
      );
      return;
    }

    final cpf = !_isPessoaJuridica ? _cpfController.text.trim() : '';
    final cnpj = _isPessoaJuridica ? _cnpjController.text.trim() : '';

    try {
      await updateProfile(
        userId: userId,
        nome: _nomeController.text.trim(),
        cpf: cpf.isNotEmpty ? cpf : cnpj,
        telefone: _telefoneController.text.trim(),
        cidade: _cidadeController.text.trim(),
        estado: _estadoSelecionado ?? '',
        bairro: _bairroController.text.trim(),
        cnpj: cnpj.isNotEmpty ? cnpj : null,
        isPessoaJuridica: _isPessoaJuridica,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar no servidor: $e')));
      return;
    }

    // Atualiza AppState em memória
    AppState.userProfile
      ..nome = _nomeController.text.trim()
      ..cpf = _cpfController.text.trim()
      ..cnpj = cnpj
      ..isPessoaJuridica = _isPessoaJuridica
      ..email = _emailController.text.trim()
      ..telefone = _telefoneController.text.trim()
      ..estado = _estadoSelecionado ?? ''
      ..cidade = _cidadeController.text.trim()
      ..bairro = _bairroController.text.trim();

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _excluirConta() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Excluir conta',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: const Text(
            'Tem certeza que deseja excluir seu cadastro? Essa ação não poderá ser desfeita.',
          ),
          actionsPadding: const EdgeInsets.only(right: 12, bottom: 8, top: 8),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE7EBF7),
                foregroundColor: const Color(0xFF1D274A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFE5E5),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);

                final getUserId =
                    widget.getUserIdAction ?? AuthService.getUserId;
                final deleteAccount =
                    widget.deleteAccountAction ?? AuthService.deleteAccount;
                final logout = widget.logoutAction ?? AuthService.logout;

                final userId = await getUserId();
                if (!mounted) return;

                if (userId != null) {
                  try {
                    await deleteAccount(userId);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir conta no servidor: $e'),
                      ),
                    );
                    return;
                  }
                }

                await logout();
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

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conta excluída com sucesso.'),
                    duration: Duration(seconds: 1),
                  ),
                );

                await Future.delayed(const Duration(seconds: 1));

                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text(
                'Excluir',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _labelColor(Set<WidgetState> states) {
    if (states.contains(WidgetState.focused)) {
      return primaryOrange;
    }
    return const Color(0xFF777777);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            const MiaudotaTopBar(titulo: 'Editar perfil', showBackButton: true),
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
                        const SizedBox(height: 4),
                        const Text(
                          'Atualize seus dados de cadastro:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF777777),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // chips PF/PJ
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Pessoa física'),
                              selected: !_isPessoaJuridica,
                              selectedColor: primaryOrange,
                              backgroundColor: const Color(0xFFE7EBF7),
                              labelStyle: TextStyle(
                                color: !_isPessoaJuridica
                                    ? Colors.white
                                    : const Color(0xFF1D274A),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              onSelected: (selected) =>
                                  setState(() => _isPessoaJuridica = false),
                            ),
                            ChoiceChip(
                              label: const Text('Pessoa jurídica'),
                              selected: _isPessoaJuridica,
                              selectedColor: primaryOrange,
                              backgroundColor: const Color(0xFFE7EBF7),
                              labelStyle: TextStyle(
                                color: _isPessoaJuridica
                                    ? Colors.white
                                    : const Color(0xFF1D274A),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              onSelected: (selected) =>
                                  setState(() => _isPessoaJuridica = true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // DOCUMENTO: CPF ou CNPJ
                        if (!_isPessoaJuridica)
                          TextFormField(
                            key: const Key('cpfField'),
                            controller: _cpfController,
                            decoration: _inputDecoration('Digite seu CPF*'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe seu CPF';
                              }
                              if (value.replaceAll(RegExp(r'\D'), '').length <
                                  11) {
                                return 'Informe um CPF válido';
                              }
                              return null;
                            },
                          )
                        else
                          TextFormField(
                            key: const Key('cnpjField'),
                            controller: _cnpjController,
                            decoration: _inputDecoration('Digite seu CNPJ*'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe seu CNPJ';
                              }
                              if (value.replaceAll(RegExp(r'\D'), '').length <
                                  14) {
                                return 'Informe um CNPJ válido';
                              }
                              return null;
                            },
                          ),

                        const SizedBox(height: 14),

                        TextFormField(
                          key: const Key('nomeField'),
                          controller: _nomeController,
                          decoration: _inputDecoration(
                            'Digite seu nome completo*',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu nome completo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          key: const Key('emailField'),
                          controller: _emailController,
                          decoration: _inputDecoration('Digite seu e-mail*'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu e-mail';
                            }
                            if (!value.contains('@')) {
                              return 'Informe um e-mail válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          key: const Key('telefoneField'),
                          controller: _telefoneController,
                          decoration: _inputDecoration('Digite seu telefone*'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu telefone';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        DropdownButtonFormField<String>(
                          key: const Key('estadoField'),
                          value: _estadoSelecionado,
                          decoration: _inputDecoration('Estado*'),
                          items: estadosBrasil.map((uf) {
                            return DropdownMenuItem(value: uf, child: Text(uf));
                          }).toList(),
                          onChanged: (uf) {
                            setState(() => _estadoSelecionado = uf);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione um estado';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _cidadeController,
                          decoration: _inputDecoration('Cidade*'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a cidade';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _bairroController,
                          decoration: _inputDecoration('Bairro*'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o bairro';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          key: const Key('salvarButton'),
                          onPressed: _salvarPerfil,
                          child: const Text(
                            'Salvar',
                            style: TextStyle(
                              fontFamily: 'PoetsenOne',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFE5E5),
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _excluirConta,
                            child: const Text(
                              'Excluir conta',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
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
}
