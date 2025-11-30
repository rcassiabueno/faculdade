import 'package:flutter/material.dart';
import 'forgot_password_page.dart';
import 'pages/home_page.dart';
import 'services/auth_service.dart';
import '../../theme/colors.dart';
import 'pages/signup_page.dart';
import 'pages/terms_page.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/global_loader.dart';

class LoginPage extends StatefulWidget {
  final Future<void> Function(String email, String senha) loginAction;

  const LoginPage({super.key, this.loginAction = AuthService.login});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  bool _carregando = false;
  bool _obscurePassword = true;

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    GlobalLoader.show(context);

    try {
      await widget.loginAction(
        _emailController.text.trim(),
        _senhaController.text.trim(),
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

  Color _labelColor(Set<WidgetState> states) {
    if (states.contains(WidgetState.focused)) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Image.asset('assets/images/logo.png', width: 160),
                      const SizedBox(height: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Entre com a sua conta',
                      style: TextStyle(
                        fontFamily: 'PoetsenOne',
                        fontSize: 18,
                        color: Colors.orange,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // E-MAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDecoration('Digite seu e-mail*'),
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
                  const SizedBox(height: 12),

                  // SENHA
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _obscurePassword,
                    decoration: _fieldDecoration('Digite sua senha*').copyWith(
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe sua senha';
                      }
                      if (value.trim().length < 4) {
                        return 'A senha deve ter pelo menos 4 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
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
                            'Entrar',
                            style: TextStyle(
                              fontFamily: 'PoetsenOne',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Esqueceu a senha',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color(0xFF777777),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignupPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryOrange),
                      minimumSize: const Size(double.infinity, 44),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    child: const Text(
                      'Criar nova conta',
                      style: TextStyle(
                        fontFamily: 'PoetsenOne',
                        color: primaryOrange,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  TextButton(
                    style: TextButton.styleFrom(alignment: Alignment.center),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TermsPage()),
                      );
                    },
                    child: const Text(
                      'Termo de uso e\nPolítica de privacidade\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color(0xFF777777),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
