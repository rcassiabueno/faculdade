import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miaudota_app/theme/colors.dart';
import 'package:miaudota_app/services/auth_service.dart';
import 'package:miaudota_app/utils/global_loader.dart';
import 'package:miaudota_app/utils/snackbar_utils.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'home_page.dart';
import 'package:miaudota_app/components/miaudota_top_bar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _senha2Controller = TextEditingController();

  bool _carregando = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  bool _isPessoaJuridica = false;

  final _telefoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cnpjMaskFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _senha2Controller.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: MaterialStateTextStyle.resolveWith(
        (states) => TextStyle(
          color: _labelColor(states),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _criarConta() async {
    if (!_formKey.currentState!.validate()) return;

    // pega só os dígitos de CPF ou CNPJ
    final cpfDigits = !_isPessoaJuridica
        ? _cpfMaskFormatter.getUnmaskedText()
        : '';
    final cnpjDigits = _isPessoaJuridica
        ? _cnpjMaskFormatter.getUnmaskedText()
        : '';

    setState(() => _carregando = true);
    GlobalLoader.show(context);

    try {
      await AuthService.signup(
        nome: _nomeController.text.trim(),
        cpf: cpfDigits.isNotEmpty ? cpfDigits : cnpjDigits,
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        senha: _senhaController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      SnackbarUtils.showError(
        context,
        e.toString().replaceFirst('Exception:', '').trim(),
      );
    } finally {
      GlobalLoader.hide();
      if (mounted) setState(() => _carregando = false);
    }
  }

  Color _labelColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.focused)) {
      return primaryOrange;
    }
    return const Color(0xFF777777);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            const MiaudotaTopBar(titulo: 'Criar conta', showBackButton: true),

            // Conteúdo
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: size.height * 0.7),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
                            'Para realizar o cadastro preencha os dados abaixo:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            ),
                          ),
                          const SizedBox(height: 20),

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
                                onSelected: (selected) {
                                  setState(() {
                                    _isPessoaJuridica = false;
                                  });
                                },
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
                                onSelected: (selected) {
                                  setState(() {
                                    _isPessoaJuridica = true;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Documento (CPF ou CNPJ) – vem antes do nome
                          if (!_isPessoaJuridica)
                            TextFormField(
                              controller: _cpfController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_cpfMaskFormatter],
                              decoration: _fieldDecoration('Digite seu CPF*'),
                              validator: (v) {
                                final digits =
                                    v?.replaceAll(RegExp(r'\D'), '') ?? '';
                                if (digits.isEmpty) {
                                  return 'Informe seu CPF';
                                }
                                if (digits.length != 11) {
                                  return 'Informe um CPF válido';
                                }
                                return null;
                              },
                            )
                          else
                            TextFormField(
                              controller: _cnpjController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_cnpjMaskFormatter],
                              decoration: _fieldDecoration('Digite seu CNPJ*'),
                              validator: (v) {
                                final digits =
                                    v?.replaceAll(RegExp(r'\D'), '') ?? '';
                                if (digits.isEmpty) {
                                  return 'Informe seu CNPJ';
                                }
                                if (digits.length != 14) {
                                  return 'Informe um CNPJ válido';
                                }
                                return null;
                              },
                            ),

                          const SizedBox(height: 12),

                          // NOME (depois do CPF/CNPJ)
                          TextFormField(
                            controller: _nomeController,
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ\s]"),
                              ),
                            ],
                            decoration: _fieldDecoration(
                              'Digite seu nome completo*',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe seu nome completo';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // E-MAIL
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _fieldDecoration('Digite seu e-mail*'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe seu e-mail';
                              }
                              if (!v.contains('@')) {
                                return 'E-mail inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // TELEFONE
                          TextFormField(
                            controller: _telefoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_telefoneMaskFormatter],
                            decoration: _fieldDecoration(
                              'Digite seu número de celular*',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Informe seu telefone'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // SENHA
                          TextFormField(
                            controller: _senhaController,
                            obscureText: _obscurePassword,
                            decoration: _fieldDecoration('Digite sua senha*')
                                .copyWith(
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    child: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFF777777),
                                    ),
                                  ),
                                ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe sua senha';
                              }
                              if (v.length < 6) {
                                return 'A senha deve ter no mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // REPETIR SENHA
                          TextFormField(
                            controller: _senha2Controller,
                            obscureText: _obscurePasswordConfirm,
                            decoration: _fieldDecoration('Repita sua senha*')
                                .copyWith(
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscurePasswordConfirm =
                                            !_obscurePasswordConfirm;
                                      });
                                    },
                                    child: Icon(
                                      _obscurePasswordConfirm
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFF777777),
                                    ),
                                  ),
                                ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Repita a senha';
                              }
                              if (v != _senhaController.text) {
                                return 'As senhas não coincidem';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // BOTÃO CRIAR CONTA
                          ElevatedButton(
                            onPressed: _carregando ? null : _criarConta,
                            child: _carregando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Criar conta',
                                    style: TextStyle(
                                      fontFamily: 'PoetsenOne',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 12),

                          // VOLTAR PARA LOGIN
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: primaryOrange),
                              minimumSize: const Size(double.infinity, 44),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Entrar com a minha conta',
                              style: TextStyle(
                                color: primaryOrange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
