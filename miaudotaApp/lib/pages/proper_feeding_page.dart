import 'package:flutter/material.dart';
import 'package:miaudota_app/components/miaudota_bottom_nav.dart';
import 'package:miaudota_app/theme/colors.dart';

class ProperFeedingPage extends StatelessWidget {
  const ProperFeedingPage({super.key});

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
                    'Alimentação Adequada',
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
                        'assets/images/alimentacao.png',
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Alimentação Adequada: Nutrição que Gera Saúde e Vitalidade',
                      style: TextStyle(
                        fontFamily: 'PoetsenOne',
                        fontSize: 18,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A dieta do seu pet é o combustível para uma vida longa, ativa e feliz. Oferecer a nutrição correta fortalece a imunidade e mantém o peso ideal.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      '🥣 Escolhendo a Ração Certa: O Guia Definitivo',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _bullet(
                      'Qualidade é prioridade: prefira rações Premium ou Super Premium, com proteínas de boa qualidade e sem corantes desnecessários.',
                    ),
                    _bullet(
                      'Filhotes: precisam de mais calorias e nutrientes para crescer.',
                    ),
                    _bullet(
                      'Adultos: rações de manutenção para peso e saúde equilibrados.',
                    ),
                    _bullet(
                      'Idosos (Sênior): fórmulas com menos calorias e suporte às articulações.',
                    ),
                    _bullet(
                      'Considere necessidades específicas: castração, porte do animal ou condições de saúde indicadas pelo veterinário.',
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      '⚠️ Alimentos Proibidos: O que NUNCA Oferecer',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _bullet('Chocolate'),
                    _bullet('Uvas e passas'),
                    _bullet('Cebola e alho'),
                    _bullet('Abacate'),
                    _bullet('Café, bebidas alcoólicas e massas com fermento'),
                    _bullet('Ossos cozidos (podem lascar e perfurar órgãos)'),

                    const SizedBox(height: 16),
                    const Text(
                      '👩‍⚕️ A Regra de Ouro: Consulte o Veterinário',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _bullet(
                      'Plano alimentar: somente o veterinário pode definir a melhor dieta, quantidade e frequência de refeições.',
                    ),
                    _bullet(
                      'Hidratação: mantenha sempre potes com água fresca e limpa disponíveis e lave-os diariamente.',
                    ),
                    _bullet(
                      'Transição de ração: faça a mudança de forma gradual por 7 a 10 dias, misturando a ração antiga com a nova.',
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
