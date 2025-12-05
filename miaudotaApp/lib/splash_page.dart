import 'package:flutter/material.dart';
import 'package:miaudota_app/pages/home_page.dart';
import 'package:miaudota_app/login_page.dart';
import 'package:miaudota_app/services/auth_service.dart';
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
    Future.delayed(const Duration(seconds: 1), () async {
      final usuario = await AuthService.getUsuarioLocal();

      if (!mounted) return;

      if (usuario != null) {
        // Atualiza estado global
        AppState.atualizarPerfilAPartirDoJson(usuario);

        // Vai para Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        // Vai para Login
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
