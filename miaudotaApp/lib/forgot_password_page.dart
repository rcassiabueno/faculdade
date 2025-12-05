import 'package:flutter/material.dart';
import 'package:miaudota_app/theme/colors.dart';
import 'package:miaudota_app/services/auth_service.dart';
import 'package:miaudota_app/utils/global_loader.dart';
import 'package:miaudota_app/utils/snackbar_utils.dart';
import 'package:miaudota_app/components/miaudota_top_bar.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ForgotPasswordPage extends StatefulWidget {
  /// Permite injetar uma função fake/mocada nos testes.
  /// No app normal, usa AuthService.resetPassword.
  final Future<void> Function({
    required String email,
    String? cpf,
    String? cnpj,
    required String novaSenha,
  })
  resetPasswordAction;

  const ForgotPasswordPage({
    super.key,
    this.resetPasswordAction = AuthService.resetPassword,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _docController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  bool _carregando = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  bool _isPessoaJuridica = false;

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
    _emailController.dispose();
    _docController.dispose();
    _novaSenhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  Future<void> _redefinirSenha() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    GlobalLoader.show(context);

    try {
      // pega só os dígitos do documento
      final docDigits = _docController.text.replaceAll(RegExp(r'\D'), '');

      String? cpf;
      String? cnpj;

      if (_isPessoaJuridica) {
        cnpj = docDigits;
      } else {
        cpf = docDigits;
      }

      await widget.resetPasswordAction(
        email: _emailController.text.trim(),
        cpf: cpf,
        cnpj: cnpj,
        novaSenha: _novaSenhaController.text.trim(),
      );

      if (!mounted) return;

      SnackbarUtils.showSuccess(
        context,
        'Senha redefinida com sucesso. Agora faça login com a nova senha.',
      );

      Navigator.pop(context); // volta pra tela de login
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          e.toString().replaceFirst('Exception:', '').trim(),
        );
      }
    } finally {
      GlobalLoader.hide();
      if (mounted) setState(() => _carregando = false);
    }
  }

  Color _labelColor(Set<WidgetState> states) {
    if (states.contains(WidgetState.focused)) {
      return primaryOrange;
    }
    return const Color(0xFF777777);
  }

  InputDecoration _fieldDecoration(String label) {
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

  @override
  Widget build(BuildContext context) {
    final docLabel = _isPessoaJuridica ? 'Digite seu CNPJ*' : 'Digite seu CPF*';

    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            const MiaudotaTopBar(
              titulo: 'Redefinir senha',
              showBackButton: true,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        const Text(
                          'Informe seu e-mail, documento (CPF ou CNPJ) e a nova senha para redefinir o acesso.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF777777),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Seleção PF / PJ
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
                                  _docController.clear();
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
                                  _docController.clear();
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

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
                              return 'Informe um e-mail válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // CPF ou CNPJ
                        TextFormField(
                          controller: _docController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            _isPessoaJuridica
                                ? _cnpjMaskFormatter
                                : _cpfMaskFormatter,
                          ],
                          decoration: _fieldDecoration(docLabel),
                          validator: (v) {
                            final digits =
                                v?.replaceAll(RegExp(r'\D'), '') ?? '';
                            if (digits.isEmpty) {
                              return _isPessoaJuridica
                                  ? 'Informe seu CNPJ'
                                  : 'Informe seu CPF';
                            }
                            if (!_isPessoaJuridica && digits.length != 11) {
                              return 'CPF incompleto';
                            }
                            if (_isPessoaJuridica && digits.length != 14) {
                              return 'CNPJ incompleto';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // NOVA SENHA
                        TextFormField(
                          controller: _novaSenhaController,
                          obscureText: _obscurePassword,
                          decoration: _fieldDecoration('Nova senha*').copyWith(
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
                              return 'Informe a nova senha';
                            }
                            if (v.length < 6) {
                              return 'A senha deve ter no mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // CONFIRMAR SENHA
                        TextFormField(
                          controller: _confirmaSenhaController,
                          obscureText: _obscurePasswordConfirm,
                          decoration: _fieldDecoration('Confirme a nova senha*')
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
                              return 'Confirme a nova senha';
                            }
                            if (v != _novaSenhaController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _carregando ? null : _redefinirSenha,
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
                                  'Redefinir senha',
                                  style: TextStyle(
                                    fontFamily: 'PoetsenOne',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
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
    );
  }
}
