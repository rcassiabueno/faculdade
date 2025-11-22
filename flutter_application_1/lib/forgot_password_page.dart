import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  /*************  ✨ Windsurf Command ⭐  *************/
  /// Builds a Scaffold with a white background, an AppBar with a title
  /// 'Redefinir Senha' and a body containing a Text with a message
  /// to enter an email address to receive a link to reset the password,
  /// a TextField to enter the email address, and an ElevatedButton to send
  /// the link. The ElevatedButton displays a SnackBar with a message
  /// indicating that the email address must be registered to receive the link.
  /*******  e6f1a0d2-cafc-4148-a634-d45f1d0a7d29  *******/
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2DE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE0B5),
        elevation: 0,
        title: const Text(
          'Redefinir Senha',
          style: TextStyle(fontFamily: 'PoetsenOne', color: Color(0xFF1D274A)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1D274A)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Digite seu e-mail para enviarmos um link de redefinição de senha.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF1D274A)),
            ),
            const SizedBox(height: 20),
            const TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Seu e-mail'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Se o e-mail estiver cadastrado, enviaremos um link para redefinir a senha.",
                    ),
                  ),
                );
              },
              child: const Text(
                'Enviar link',
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
    );
  }
}

// TODO Implement this library.
