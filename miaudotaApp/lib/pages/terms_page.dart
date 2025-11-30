import 'package:flutter/material.dart';
import 'package:miaudota_app/components/miaudota_top_bar.dart';
import 'package:miaudota_app/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            const MiaudotaTopBar(
              titulo: 'Termo de uso e\nPolítica de privacidade',
              showBackButton: true,
              maxLines: 2,
            ),
            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF1D274A),
                    ),
                    children: [
                      // TÍTULO TERMOS
                      const TextSpan(
                        text: 'Termo de Uso – Aplicativo Miaudota!\n\n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: 'Última atualização: 20 de novembro de 2025\n\n',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),

                      const TextSpan(text: 'Bem-vindo(a) ao '),
                      const TextSpan(
                        text: 'Miaudota!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            '.\n\nEstes Termos de Uso ("Termos") regem o seu acesso e uso do nosso aplicativo móvel ("Aplicativo"), desenvolvido pelo Grupo 14 da disciplina "HANDS ON WORK VIII" do Curso de Análise e Desenvolvimento de Sistemas na Universidade do Vale do Itajaí.\n\n'
                            'Ao criar uma conta ou utilizar nosso Aplicativo, você concorda integralmente com estes Termos. Se você não concorda com qualquer parte deste documento, não deverá utilizar o Aplicativo.\n\n',
                      ),

                      // 1. O Serviço
                      const TextSpan(
                        text: '1. O Serviço\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            '1.1. O Miaudota! é uma plataforma gratuita que tem como missão facilitar a adoção responsável de animais de estimação e fornecer conteúdo educativo sobre cuidados com pets.\n\n',
                      ),
                      const TextSpan(
                        text: '1.2. Nossa Função: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            'Atuamos exclusivamente como uma ponte, conectando potenciais adotantes a tutores, protetores ou abrigos ("Anunciantes") que desejam encontrar um novo lar para um animal.\n\n',
                      ),

                      // 2. Cadastro de Usuário
                      const TextSpan(
                        text: '2. Cadastro de Usuário\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            '2.1. Para utilizar as funcionalidades de adoção, é necessário criar uma conta de usuário. Você concorda em fornecer informações verdadeiras, precisas e completas durante o cadastro, incluindo:\n'
                            '• Nome Completo\n'
                            '• CPF\n'
                            '• E-mail\n'
                            '• Telefone\n'
                            '• Endereço (Estado, Cidade, Bairro)\n\n',
                      ),
                      const TextSpan(
                        text:
                            '2.2. Você é o único responsável pela segurança de sua senha e por todas as atividades que ocorrerem em sua conta. O Miaudota! não se responsabiliza por acessos não autorizados decorrentes de negligência do usuário com suas credenciais.\n\n',
                      ),

                      // 3. Responsabilidades e Isenções
                      const TextSpan(
                        text: '3. Responsabilidades e Isenções\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '3.1. '),
                      const TextSpan(
                        text:
                            'O Miaudota! NÃO PARTICIPA do processo de adoção. ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            'Nossa responsabilidade se limita a conectar as partes interessadas. Todo o processo subsequente, incluindo, mas não se limitando a:\n'
                            '• Agendamento de visitas;\n'
                            '• Entrevistas;\n'
                            '• Verificação de compatibilidade;\n'
                            '• Transporte e entrega do animal;\n'
                            '• Assinatura de termos de adoção e responsabilidade;\n'
                            'é de responsabilidade exclusiva e integral do adotante e do Anunciante.\n\n',
                      ),
                      const TextSpan(
                        text: '3.2. Veracidade das Informações: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            'O Anunciante é o único responsável pela veracidade, precisão e legalidade das informações cadastradas sobre os animais (fotos, nome, espécie, raça, idade, estado de saúde, comportamento e descrição). O Miaudota! não realiza qualquer verificação prévia, visita, avaliação veterinária ou comportamental dos animais anunciados.\n\n',
                      ),
                      const TextSpan(
                        text: '3.3. Saúde e Comportamento do Animal: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            'Não oferecemos garantias sobre a saúde, o temperamento ou o histórico de qualquer animal listado no Aplicativo. Recomendamos fortemente que o adotante realize uma avaliação veterinária completa antes de finalizar a adoção.\n\n',
                      ),
                      const TextSpan(
                        text:
                            '3.4. Ao utilizar o serviço, você isenta o Miaudota! e seus desenvolvedores de qualquer responsabilidade, seja cível ou criminal, decorrente de problemas, disputas ou danos de qualquer natureza (físicos, morais, financeiros) que surjam da interação entre usuários ou do processo de adoção.\n\n',
                      ),

                      // 4. Conteúdo Gerado pelo Usuário
                      const TextSpan(
                        text: '4. Conteúdo Gerado pelo Usuário\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            '4.1. Os usuários podem cadastrar animais para adoção. Ao fazer isso, você declara que possui o direito de disponibilizar tal animal para adoção e que todas as informações fornecidas são verdadeiras.\n\n'
                            '4.2. É proibido publicar conteúdo que seja ilegal, falso, enganoso, difamatório ou que viole os direitos de terceiros. Reservamo-nos o direito de remover qualquer conteúdo ou suspender contas que violem estes Termos, sem aviso prévio.\n\n',
                      ),

                      // 5. Custos
                      const TextSpan(
                        text: '5. Custos\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            '5.1. O uso do aplicativo Miaudota! é, no momento, 100% gratuito. Não há taxas de assinatura, funcionalidades pagas ou anúncios.\n\n',
                      ),

                      // 6. Privacidade e Dados
                      const TextSpan(
                        text: '6. Privacidade e Dados\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            '6.1. A coleta e o uso de seus dados pessoais são regidos pela nossa Política de Privacidade, que é parte integrante destes Termos. Ao concordar com os Termos de Uso, você também concorda com a nossa Política de Privacidade.\n\n',
                      ),

                      // 7. Modificações
                      const TextSpan(
                        text: '7. Modificações nos Termos\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            '7.1. Podemos revisar e atualizar estes Termos de Uso periodicamente. A versão mais recente estará sempre disponível no Aplicativo. Notificaremos os usuários sobre alterações significativas. O uso contínuo do Aplicativo após as alterações constitui sua aceitação dos novos Termos.\n\n',
                      ),

                      // 8. Contato
                      const TextSpan(
                        text: '8. Contato\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            '8.1. Em caso de dúvidas sobre estes Termos, entre em contato conosco através do e-mail: ',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () async {
                            debugPrint("Email clicado!");
                            final uri = Uri(
                              scheme: 'mailto',
                              path: 'rcassia.bueno@gmail.com',
                            );

                            if (await launchUrl(uri)) {
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Não foi possível abrir o app de e-mail no dispositivo.",
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'rcassia.bueno@gmail.com',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: '.\n\n'),

                      const TextSpan(
                        text: '─────────────────────────────────\n\n',
                      ),

                      // POLÍTICA DE PRIVACIDADE
                      const TextSpan(
                        text:
                            'Política de Privacidade – Aplicativo Miaudota!\n\n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: 'Última atualização: 20 de novembro de 2025\n\n',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(
                        text:
                            'A sua privacidade é muito importante para o Miaudota!. Esta Política de Privacidade explica como nós, o Grupo 14 da disciplina "HANDS ON WORK VIII" (Univali), coletamos, usamos, armazenamos e protegemos seus dados pessoais, em conformidade com a Lei Geral de Proteção de Dados (LGPD - Lei nº 13.709/2018).\n\n',
                      ),

                      //  1. Dados que Coletamos
                      const TextSpan(
                        text: '1. Dados que Coletamos\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            'Coletamos os seguintes dados pessoais durante o seu cadastro e uso do aplicativo:\n'
                            '• Dados de Identificação: Nome completo, CPF.\n'
                            '• Dados de Contato: E-mail, número de telefone.\n'
                            '• Dados de Localização: Estado, cidade e bairro.\n\n',
                      ),

                      // 2. Finalidade
                      const TextSpan(
                        text: '2. Finalidade da Coleta de Dados\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            'Seus dados são utilizados estritamente para as seguintes finalidades:\n'
                            '• Autenticação e Login: Para criar e gerenciar sua conta de usuário.\n'
                            '• Viabilizar a Adoção: Para permitir que você solicite a adoção de um animal e que o Anunciante entre em contato com você para dar andamento ao processo. Seu nome e contato só são compartilhados com a outra parte após uma solicitação de adoção ser feita.\n'
                            '• Identificação e Segurança: O CPF é utilizado como um fator de identificação único para garantir a segurança da plataforma e evitar duplicidade de contas.\n'
                            '• Personalização (Futura): Seu estado e cidade poderão ser usados futuramente para filtrar e sugerir animais que estão mais próximos de você.\n\n',
                      ),

                      // 3. Compartilhamento
                      const TextSpan(
                        text: '3. Compartilhamento de Dados\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            'Nós não vendemos, alugamos ou compartilhamos seus dados pessoais com terceiros para fins de marketing ou publicidade.\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            'O compartilhamento de dados ocorre apenas nas seguintes circunstâncias:\n'
                            '• Entre Usuários para Adoção: Ao manifestar interesse em um animal, seus dados de contato (nome, e-mail, telefone) serão disponibilizados ao Anunciante do animal para que o processo de adoção possa ocorrer fora da plataforma.\n'
                            '• Requisição Legal: Poderemos compartilhar dados se formos obrigados por lei ou por ordem judicial.\n\n',
                      ),

                      // 4. Armazenamento
                      const TextSpan(
                        text: '4. Armazenamento e Segurança dos Dados\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            '4.1. Seus dados são armazenados em servidores seguros, e utilizamos medidas técnicas e administrativas para protegê-los contra acesso não autorizado, perda, alteração ou destruição.\n\n'
                            '4.2. Os dados serão mantidos em nosso sistema enquanto sua conta estiver ativa.\n\n',
                      ),

                      // 5. Direitos LGPD
                      const TextSpan(
                        text:
                            '5. Seus Direitos como Titular dos Dados (LGPD)\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            'Você, como titular dos dados, tem o direito de, a qualquer momento, solicitar:\n'
                            '• A confirmação da existência de tratamento dos seus dados.\n'
                            '• O acesso aos seus dados.\n'
                            '• A correção de dados incompletos, inexatos ou desatualizados.\n'
                            '• A anonimização, bloqueio ou eliminação de dados desnecessários ou excessivos.\n'
                            '• A portabilidade dos seus dados a outro fornecedor de serviço.\n'
                            '• A eliminação dos dados pessoais tratados com o seu consentimento.\n'
                            '• Informações sobre com quem compartilhamos seus dados.\n\n',
                      ),

                      // 6. Exclusão
                      const TextSpan(
                        text: '6. Exclusão da Conta e dos Dados\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            '6.1. Você pode solicitar a exclusão da sua conta e de todos os seus dados pessoais a qualquer momento, entrando em contato conosco pelo canal informado no final deste documento. A exclusão será processada em conformidade com os prazos legais.\n\n',
                      ),

                      //  7. Contato DPO
                      const TextSpan(
                        text: '7. Contato do Encarregado de Dados (DPO)\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            'Para exercer seus direitos ou para esclarecer qualquer dúvida sobre esta Política de Privacidade, entre em contato conosco através do e-mail: ',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () async {
                            debugPrint("Email clicado!");
                            final uri = Uri(
                              scheme: 'mailto',
                              path: 'rcassia.bueno@gmail.com',
                            );

                            if (await launchUrl(uri)) {
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Não foi possível abrir o app de e-mail no dispositivo.",
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'rcassia.bueno@gmail.com',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: '.\n'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
