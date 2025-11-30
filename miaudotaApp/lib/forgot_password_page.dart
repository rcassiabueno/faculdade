import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../services/auth_service.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/global_loader.dart';
import 'package:miaudota_app/components/miaudota_top_bar.dart';

/// Tela de "Esqueci minha senha"
///
/// Atualmente suporta apenas o fluxo de redefinição **local**:
/// - Usuário informa e-mail, CPF, nova senha e confirmação.
/// - O app chama `resetPasswordByCpfAction` (por padrão, `AuthService.resetPasswordByCpf`).
///
/// Observação:
/// - A funcionalidade de envio de link por e-mail foi desativada.
/// - A propriedade [forgotPasswordAction] é mantida apenas por compatibilidade,
///   mas não é utilizada nesta UI.
class ForgotPasswordPage extends StatefulWidget {
  /// Mantido por compatibilidade, mas não é usado na UI atual.
  final Future<void> Function(String) forgotPasswordAction;

  /// Ação utilizada para redefinir a senha localmente usando e-mail + CPF.
  final Future<void> Function({
    required String email,
    required String cpf,
    required String novaSenha,
  })
  resetPasswordByCpfAction;

  const ForgotPasswordPage({
    super.key,
    this.forgotPasswordAction = AuthService.forgotPassword,
    this.resetPasswordByCpfAction = AuthService.resetPasswordByCpf,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  // Campos da tela
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmSenhaController = TextEditingController();

  // Indica se há requisição em andamento (evita duplo clique)
  bool _enviando = false;

  Color _labelColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.focused)) {
      return primaryOrange; // focado → laranja
    }
    return const Color(0xFF777777); // sem foco → cinza
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

  @override
  void dispose() {
    _emailController.dispose();
    _cpfController.dispose();
    _novaSenhaController.dispose();
    _confirmSenhaController.dispose();
    super.dispose();
  }

  /// Centraliza a lógica da redefinição local de senha:
  /// - valida o formulário
  /// - mostra loader
  /// - chama [resetPasswordByCpfAction]
  /// - exibe snackbar de sucesso ou erro
  Future<void> _redefinirSenha() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _enviando = true);
    GlobalLoader.show(context);

    try {
      final novaSenha = _novaSenhaController.text.trim();
      final confirmSenha = _confirmSenhaController.text.trim();

      if (novaSenha.length < 6) {
        throw Exception('A senha deve ter no mínimo 6 caracteres');
      }
      if (novaSenha != confirmSenha) {
        throw Exception('As senhas não coincidem');
      }

      await widget.resetPasswordByCpfAction(
        email: _emailController.text.trim(),
        cpf: _cpfController.text.trim(),
        novaSenha: novaSenha,
      );

      SnackbarUtils.showSuccess(context, 'Senha redefinida com sucesso');
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      SnackbarUtils.showError(
        context,
        e.toString().replaceFirst('Exception:', '').trim(),
      );
    } finally {
      GlobalLoader.hide();
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Esqueceu a senha?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PoetsenOne',
                          fontSize: 18,
                          color: primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Digite seu e-mail, CPF e a nova senha para redefinir sua senha aqui mesmo no aplicativo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF777777),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // E-mail
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: _fieldDecoration('Digite seu e-mail*'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe seu e-mail';
                          }
                          final email = value.trim();
                          final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                          if (!regex.hasMatch(email)) {
                            return 'Informe um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // CPF
                      TextFormField(
                        controller: _cpfController,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration('CPF*'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe seu CPF';
                          }
                          if (value.replaceAll(RegExp(r'\D'), '').length < 11) {
                            return 'CPF inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Nova senha
                      TextFormField(
                        controller: _novaSenhaController,
                        obscureText: true,
                        decoration: _fieldDecoration('Nova senha*'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe a nova senha';
                          }
                          if (value.length < 6) {
                            return 'Senha muito curta (mínimo 6 caracteres)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Confirmar senha
                      TextFormField(
                        controller: _confirmSenhaController,
                        obscureText: true,
                        decoration: _fieldDecoration('Confirmar senha*'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Confirme a senha';
                          }
                          if (value != _novaSenhaController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Botão "Redefinir senha"
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _enviando ? null : _redefinirSenha,
                          child: _enviando
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
                      ),
                    ],
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
