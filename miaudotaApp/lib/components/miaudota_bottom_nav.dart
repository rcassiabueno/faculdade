import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../main.dart';
import '../pages/home_page.dart';
import '../pages/adoption_page.dart';
import '../pages/tips_page.dart';
import '../pages/profile/profile_page.dart';

class MiaudotaBottomNav extends StatelessWidget {
  final int currentIndex;

  const MiaudotaBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: primaryOrange,
      unselectedItemColor: const Color(0xFF999999),
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == currentIndex) return; // já estou nessa aba, não faz nada

        if (index == 0) {
          // Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else if (index == 1) {
          // Adotar
          if (AppState.petsParaAdocao.isNotEmpty) {
            final pet = AppState.petsParaAdocao.first;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdoptionPage(pet: pet)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF1D274A),
                content: const Text(
                  'Nenhum pet disponível para adoção no momento.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        } else if (index == 2) {
          // Dicas
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TipsPage()),
          );
        } else if (index == 3) {
          // Perfil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Adotar'),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline),
          label: 'Dicas',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
