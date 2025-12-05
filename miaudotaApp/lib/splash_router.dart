import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORTS CORRIGIDOS
import 'package:miaudota_app/pages/home_page.dart';
import 'package:miaudota_app/login_page.dart';

class SplashRouter extends StatelessWidget {
  const SplashRouter({super.key});

  Future<bool> _hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasToken = snapshot.data ?? false;

        return hasToken ? const HomePage() : const LoginPage();
      },
    );
  }
}
