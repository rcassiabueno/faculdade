import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'login_page.dart';
import 'services/auth_service.dart';
import 'package:miaudota_app/main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      final usuario = await AuthService.getUsuarioLogado();

      if (!mounted) return;

      if (usuario != null) {
        AppState.atualizarPerfilAPartirDoJson(usuario);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/carregamento.png', width: 160),
            const SizedBox(height: 24),
            const Text(
              'Conectando lares a patinhas...',
              style: TextStyle(fontSize: 16, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
