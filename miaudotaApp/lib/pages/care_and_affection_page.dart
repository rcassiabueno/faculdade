import 'package:flutter/material.dart';
import 'package:miaudota_app/components/miaudota_bottom_nav.dart';
import 'package:miaudota_app/theme/colors.dart';
import 'package:miaudota_app/components/miaudota_top_bar.dart';

class CareAndAffectionPage extends StatelessWidget {
  const CareAndAffectionPage({super.key});

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
            const MiaudotaTopBar(
              titulo: 'Cuidado e Afeto',
              showBackButton: true,
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
                        'assets/images/carregamento.png',
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cuidado e Afeto: Construindo uma Amizade para a Vida Toda',
                      style: TextStyle(
                        fontFamily: 'PoetsenOne',
                        fontSize: 18,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A chegada de um novo amigo é um momento de pura alegria! O afeto é o alicerce para uma relação de confiança e lealdade. Aqui estão as melhores práticas para garantir que seu pet se sinta amado, seguro e parte da família desde o primeiro dia.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      '❤️ A Arte da Paciência: Os Primeiros Dias',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Lembre-se que seu pet passou por uma grande mudança. Ele pode estar tímido, assustado ou ansioso. A paciência é sua maior aliada.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    _bullet(
                      'Dê Espaço: Deixe que ele explore o novo ambiente no seu próprio ritmo. Crie um "porto seguro" onde ele possa se refugiar quando se sentir sobrecarregado.',
                    ),
                    _bullet(
                      'Fale com Suavidade: Use um tom de voz calmo e gentil. Evite barulhos altos e movimentos bruscos nos primeiros dias.',
                    ),
                    _bullet(
                      'Interações Positivas: Não force o contato. Sente-se no chão e espere que ele venha até você. Quando ele se aproximar, ofereça um petisco ou carinho suave.',
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      '🐾 Rotina é Tudo: Criando Segurança e Previsibilidade',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Animais prosperam com rotinas. Saber o que esperar a cada dia diminui a ansiedade e acelera a adaptação.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    _bullet(
                      'Horários Fixos: Estabeleça e mantenha horários para alimentação, passeios e idas ao "banheiro".',
                    ),
                    _bullet(
                      'Momentos de Brincadeira: Separe de 15 a 30 minutos por dia para brincadeiras focadas.',
                    ),
                    _bullet(
                      'Hora do Descanso: Respeite o sono do seu pet. Ensine todos em casa que o local de descanso é sagrado.',
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      '💬 Entendendo o que Ele Sente: A Linguagem do Amor',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1D274A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Seu pet não fala sua língua, mas se comunica o tempo todo através da linguagem corporal. Aprender a "ouvi-lo" é uma forma profunda de cuidado.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    _bullet(
                      'Sinais de Felicidade: Rabo relaxado, corpo solto, orelhas neutras, ronronar (gatos) e buscar contato físico.',
                    ),
                    _bullet(
                      'Sinais de Medo ou Estresse: Rabo entre as pernas, corpo encolhido, orelhas para trás, lamber os lábios, bocejar fora de hora ou se esconder.',
                    ),
                    _bullet(
                      'Como Reagir: Se notar estresse, afaste o pet da situação e ofereça segurança. Reforce os momentos de felicidade com carinho.',
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
