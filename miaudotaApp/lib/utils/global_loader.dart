import 'package:flutter/material.dart';

class GlobalLoader {
  static OverlayEntry? _currentLoader;

  static void show(BuildContext context) {
    // Se já tiver loader na tela, não cria outro
    if (_currentLoader != null) return;

    final overlay = Overlay.of(context, rootOverlay: true);

    _currentLoader = OverlayEntry(
      builder: (_) => Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(alpha: 0.3),
          ),
          const Center(child: _LogoCircleLoader()),
        ],
      ),
    );

    overlay.insert(_currentLoader!);
  }

  static void hide() {
    if (_currentLoader != null) {
      _currentLoader!.remove();
      _currentLoader = null;
    }
  }
}

class _LogoCircleLoader extends StatelessWidget {
  const _LogoCircleLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 95,
      height: 95,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width: 95,
            height: 95,
            child: CircularProgressIndicator(
              strokeWidth: 4.5,
              valueColor: AlwaysStoppedAnimation(Color(0xFFFF8A00)),
            ),
          ),
          Image.asset('assets/images/logo.png', width: 46, height: 46),
        ],
      ),
    );
  }
}
