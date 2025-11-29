import 'package:flutter/material.dart';

class GlobalLoader {
  static OverlayEntry? _currentLoader;

  static void show(BuildContext context) {
    if (_currentLoader != null) return;

    _currentLoader = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Fundo escuro
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.3),
          ),
          // Loader no centro
          const Center(child: _LogoCircleLoader()),
        ],
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_currentLoader!);
  }

  static void hide() {
    _currentLoader?.remove();
    _currentLoader = null;
  }
}

/// Widget com o círculo + logo no centro
class _LogoCircleLoader extends StatelessWidget {
  const _LogoCircleLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 95, // 🔥 antes estava 72 — aumentei
      height: 95, // 🔥 aumenta o circulo e o espaço interno
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width: 95,
            height: 95,
            child: CircularProgressIndicator(
              strokeWidth: 4.5,
              valueColor: AlwaysStoppedAnimation(
                Color(0xFFFF8A00),
              ), // opcional — deixa barra mais grossa e visível
            ),
          ),
          Image.asset(
            'assets/images/logo.png',
            width: 46, // aumentei levemente a logo para equilibrar visual
            height: 46,
          ),
        ],
      ),
    );
  }
}
