import 'package:flutter/material.dart';
import 'package:miaudota_app/components/miaudota_bottom_nav.dart';
import 'package:miaudota_app/theme/colors.dart';

class SafeHomePage extends StatelessWidget {
  const SafeHomePage({super.key});

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 12, color: Color(0xFF1D274A)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1D274A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                    'Lar Seguro',
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/lar.png',
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Lar Seguro: Seu Santuário, o Mundo Dele',
                      style: TextStyle(
                        fontFamily: 'PoetsenOne',
                        fontSize: 18,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sua casa é o universo do seu novo companheiro. Prepará-la é um ato de amor e responsabilidade para prevenir acidentes e garantir conforto.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      '✅ Checklist de Segurança: Deixando a Casa à Prova de Pets',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _bullet(
                      'Produtos Perigosos: Guarde produtos de limpeza, medicamentos e venenos em armários altos e bem fechados.',
                    ),
                    _bullet(
                      'Fios e Eletrônicos: Organize cabos em canaletas ou esconda-os para evitar choques elétricos.',
                    ),
                    _bullet(
                      'Plantas Tóxicas: Pesquise quais plantas são venenosas para cães e gatos e mantenha-as fora de alcance.',
                    ),
                    _bullet(
                      'Lixo Seguro: Use lixeiras com tampa, principalmente na cozinha e no banheiro.',
                    ),
                    _bullet(
                      'Janelas e Sacadas: Instale redes de proteção, mesmo em andares baixos.',
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      '🏡 Criando o Cantinho Perfeito: Conforto e Estímulo',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _bullet(
                      'Refúgio: Escolha um local calmo para a caminha, onde o pet possa relaxar.',
                    ),
                    _bullet(
                      'Estação de Alimentação: Mantenha potes limpos em um local fixo; para gatos, longe da caixa de areia.',
                    ),
                    _bullet(
                      'Para cães: Ofereça brinquedos de roer, bolinhas e brinquedos interativos.',
                    ),
                    _bullet(
                      'Para gatos: Providencie arranhadores, prateleiras, tocas e brinquedos com penas.',
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
