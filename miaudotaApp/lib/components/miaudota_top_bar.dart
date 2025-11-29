import 'package:flutter/material.dart';

class MiaudotaTopBar extends StatelessWidget {
  final String titulo;
  final bool showBackButton;

  const MiaudotaTopBar({
    super.key,
    required this.titulo,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFFE0B5),
      child: Row(
        children: [
          // LOGO NO LADO ESQUERDO
          Image.asset('assets/images/logo.png', height: 50),

          // TÍTULO CENTRALIZADO
          Expanded(
            child: Center(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontFamily: 'PoetsenOne',
                  fontSize: 18,
                  color: Color(0xFF1D274A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // BOTÃO VOLTAR NO LADO DIREITO (só se showBackButton = true)
          if (showBackButton)
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 22,
                color: Color(0xFF1D274A),
              ),
              onPressed: () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 48), // para compensar e manter alinhamento
        ],
      ),
    );
  }
}
