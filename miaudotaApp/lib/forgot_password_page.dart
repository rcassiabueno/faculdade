import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../services/auth_service.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/global_loader.dart';
import 'package:miaudota_app/components/miaudota_top_bar.dart';

// NOTE: Temporarily disabled email-based reset UI and 'redefinir aqui no app'.
// The email field and in-app reset toggle are commented out below; this file
// retains the backend calls and tests but hides the UI — to revert, uncomment
// the commented blocks and restore the logic in `_enviarLink`.
class ForgotPasswordPage extends StatefulWidget {
  /// Optional callback to perform the forgot-password action. It's injected
  /// to make the page testable (default uses AuthService.forgotPassword).
  final Future<void> Function(String) forgotPasswordAction;
  final Future<void> Function({required String email, required String cpf, required String novaSenha}) resetPasswordByCpfAction;

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
  final _emailController = TextEditingController();

  bool _enviando = false;
  bool _localReset = true; // keep local reset visible and enabled
  bool _useEmailLink = false; // toggle between email link and local reset
  final _cpfController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmSenhaController = TextEditingController();

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

  // In the current temporary state, email-based sending is disabled. Inform the user.
  // removed _mostrarDesativado; local reset is active

  // Centraliza a lógica do envio do link de redefinição
  // - valida o formulário
  // - mostra loader e snackbar
  // - trata exceções e garante o hide do loader
  // NOTE: this method is kept `Future<void>` (not `void`) to allow tests and `await` usage
  Future<void> _enviarLink() async {
    if (!_formKey.currentState!.validate()) return;

    // Hides keyboard
    FocusScope.of(context).unfocus();

    setState(() => _enviando = true);
    GlobalLoader.show(context);

    try {
      if (_useEmailLink) {
        // send link via email
        await widget.forgotPasswordAction(_emailController.text.trim());
        SnackbarUtils.showSuccess(context, 'Se o e-mail estiver cadastrado, enviaremos um link para redefinir a senha.');
      } else {
        // local reset (email route is intentionally not used in the UI)
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
      }
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      SnackbarUtils.showError(context, e.toString().replaceFirst('Exception:', '').trim());
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
                        'Digite seu e-mail e CPF para redefinir sua senha aqui mesmo no aplicativo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF777777),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Campo de e-mail (usado para identificar usuario)
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
                          final regex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
                          if (!regex.hasMatch(email)) return 'Informe um e-mail válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Expanded(child: Text('Enviar link por e-mail')),
                          Switch(
                            value: _useEmailLink,
                            onChanged: (v) => setState(() => _useEmailLink = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 12),
                      // CPF
                      if (!_useEmailLink) ...[
                      TextFormField(
                        controller: _cpfController,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration('CPF*'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Informe seu CPF';
                          if (value.replaceAll(RegExp(r"\D"), '').length < 11) return 'CPF inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 12),
                      // Nova senha
                      if (!_useEmailLink) ...[
                      TextFormField(
                        controller: _novaSenhaController,
                        obscureText: true,
                        decoration: _fieldDecoration('Nova senha*'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Informe a nova senha';
                          if (value.length < 6) return 'Senha muito curta (mínimo 6 caracteres)';
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
                          if (value == null || value.trim().isEmpty) return 'Confirme a senha';
                          if (value != _novaSenhaController.text) return 'As senhas não coincidem';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 12),
                      // Confirmar senha
                      TextFormField(
                        controller: _confirmSenhaController,
                        obscureText: true,
                        decoration: _fieldDecoration('Confirmar senha*'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Confirme a senha';
                          if (value != _novaSenhaController.text) return 'As senhas não coincidem';
                          return null;
                        },
                      ),
                      /*
                      const SizedBox(height: 12),
                      // Toggle para modo local (sem e-mail)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Redefinir aqui no app'),
                          Switch(
                            value: _localReset,
                            onChanged: (v) {
                              setState(() {
                                _localReset = v;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_localReset) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cpfController,
                          keyboardType: TextInputType.number,
                          decoration: _fieldDecoration('CPF*'),
                          validator: (value) {
                            if (!_localReset) return null;
                            if (value == null || value.trim().isEmpty) return 'Informe seu CPF';
                            if (value.replaceAll(RegExp(r"\D"), '').length < 11) return 'CPF inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _novaSenhaController,
                          obscureText: true,
                          decoration: _fieldDecoration('Nova senha*'),
                          validator: (value) {
                            if (!_localReset) return null;
                            if (value == null || value.isEmpty) return 'Informe a nova senha';
                            if (value.length < 6) return 'Senha muito curta (mínimo 6 caracteres)';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmSenhaController,
                          obscureText: true,
                          decoration: _fieldDecoration('Confirmar senha*'),
                          validator: (value) {
                            if (!_localReset) return null;
                            if (value == null || value.isEmpty) return 'Confirme a senha';
                            if (value != _novaSenhaController.text) return 'As senhas não coincidem';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                      */
                      const SizedBox(height: 24),

                      // Botão enviar
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _enviando ? null : _enviarLink,
                            child: _enviando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  _useEmailLink ? 'Enviar link' : 'Redefinir senha',
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
