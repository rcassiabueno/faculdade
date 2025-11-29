import 'package:flutter/material.dart';
import 'care_and_affection_page.dart';
import 'safe_home_page.dart';
import 'proper_feeding_page.dart';
import 'package:miaudota_app/components/miaudota_bottom_nav.dart';
import 'package:miaudota_app/theme/colors.dart';

//DICAS DE ADOÇÃO
class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFFFE0B5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo.png', height: 64),
                  const Text(
                    'Dicas de Adoção',
                    style: TextStyle(
                      fontFamily: 'PoetsenOne',
                      fontSize: 18,
                      color: Color(0xFF1D274A),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Conheça as melhores práticas para ser um responsável amoroso e cuidadoso.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF555555),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CARD 1 - Cuidado e Afeto
                    _TipCard(
                      title: 'Cuidado e Afeto',
                      description:
                          'Ofereça um ambiente seguro, amoroso e acolhedor para seu novo companheiro.',
                      assetImage: 'assets/images/carregamento.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CareAndAffectionPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // CARD 2 - Lar Seguro
                    _TipCard(
                      title: 'Lar Seguro',
                      description:
                          'Prepare sua casa com tudo o que o pet precisa para se adaptar com segurança.',
                      assetImage: 'assets/images/lar.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SafeHomePage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // CARD 3 - Alimentação Adequada
                    _TipCard(
                      title: 'Alimentação Adequada',
                      description:
                          'Ofereça uma dieta equilibrada e água fresca diariamente para seu amigo.',
                      assetImage: 'assets/images/alimentacao.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProperFeedingPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const MiaudotaBottomNav(currentIndex: 2),
    );
  }
}

// COMPONENTE DO CARD DE DICA
class _TipCard extends StatelessWidget {
  final String title;
  final String description;
  final String assetImage;
  final VoidCallback onTap;

  const _TipCard({
    required this.title,
    required this.description,
    required this.assetImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  assetImage,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'PoetsenOne',
                        fontSize: 15,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555555),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
