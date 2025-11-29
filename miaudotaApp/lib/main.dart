import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'splash_page.dart';
import 'package:miaudota_app/theme/colors.dart';

// Solicitação de adoção
class SolicitacaoAdocao {
  final PetParaAdocao pet;
  final String nomeInteressado;
  final String emailInteressado;
  final String telefoneInteressado;
  bool aprovado;

  SolicitacaoAdocao({
    required this.pet,
    required this.nomeInteressado,
    required this.emailInteressado,
    required this.telefoneInteressado,
    this.aprovado = false,
  });
}

class UserProfile {
  String nome;
  String cpf;
  String cnpj;
  bool isPessoaJuridica;
  String email;
  String telefone;
  String estado;
  String cidade;
  String bairro;

  UserProfile({
    this.nome = '',
    this.cpf = '',
    this.cnpj = '',
    this.isPessoaJuridica = false, // padrão: pessoa física
    this.email = '',
    this.telefone = '',
    this.estado = '',
    this.cidade = '',
    this.bairro = '',
  });
}

bool isUserProfileComplete() {
  final p = AppState.userProfile;

  return p.nome.trim().isNotEmpty &&
      p.cpf.trim().isNotEmpty &&
      p.email.trim().isNotEmpty &&
      p.telefone.trim().isNotEmpty &&
      p.estado.trim().isNotEmpty &&
      p.cidade.trim().isNotEmpty &&
      p.bairro.trim().isNotEmpty;
}

class PetAdotado {
  String nome;
  String tipo;
  bool aprovado;
  bool reprovado;

  PetAdotado({
    required this.nome,
    required this.tipo,
    this.aprovado = false,
    this.reprovado = false,
  });
}

// Lista de estados do Brasil (UFs)
const List<String> estadosBrasil = [
  'AC',
  'AL',
  'AP',
  'AM',
  'BA',
  'CE',
  'DF',
  'ES',
  'GO',
  'MA',
  'MT',
  'MS',
  'MG',
  'PA',
  'PB',
  'PR',
  'PE',
  'PI',
  'RJ',
  'RN',
  'RS',
  'RO',
  'RR',
  'SC',
  'SP',
  'SE',
  'TO',
];

class PetParaAdocao {
  String nome;
  String especie; // ex: Gato, Cachorro
  String raca; // ex: SRD, Siamês
  String idade; // ex: "15 dias", "2 anos"
  String cidade; // ex: Itajaí
  String estado; // ex: SC
  String bairro; // ex: Centro
  String descricao;
  String imagemPath;
  String telefoneTutor;

  PetParaAdocao({
    required this.nome,
    required this.especie,
    required this.raca,
    required this.idade,
    required this.cidade,
    required this.estado,
    required this.bairro,
    required this.descricao,
    required this.imagemPath,
    required this.telefoneTutor,
  });

  String get tipo => '$especie $raca';
  String get cidadeEstado => '$cidade – $estado';
}

// Estado global do aplicativo (dados simulados)
class AppState {
  static UserProfile userProfile = UserProfile(
    nome: 'Maria Silva',
    cpf: '000.000.000-00',
    email: 'maria@email.com.br',
    telefone: '(47) 99999-9999',
    estado: 'SC',
    cidade: 'Itajaí',
    bairro: 'Centro',
  );

  static final List<PetAdotado> petsAdotados = [];
  static final List<PetParaAdocao> petsParaAdocao = [];
  static final List<SolicitacaoAdocao> solicitacoesPendentes = [];

  static void atualizarPerfilAPartirDoJson(Map<String, dynamic> json) {
    userProfile = UserProfile(
      nome: (json['nome'] ?? '').toString(),
      cpf: (json['cpf'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      telefone: (json['telefone'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
      cidade: (json['cidade'] ?? '').toString(),
      bairro: (json['bairro'] ?? '').toString(),
    );
  }
}

String formatCidadeEstado({String? cidade, String? estado}) {
  final c = (cidade ?? '').trim();
  final e = (estado ?? '').trim();

  if (c.isEmpty && e.isEmpty) {
    return 'Localização não informada';
  }
  if (c.isEmpty) return e;
  if (e.isEmpty) return c;
  return '$c – $e'; // ex.: Itajaí – SC
}

void main() {
  runApp(const MiaudotaApp());
}

Future<void> abrirWhatsApp(
  BuildContext context, {
  required String numeroComDDD,
  required String mensagem,
}) async {
  final uri = Uri.parse(
    'https://wa.me/$numeroComDDD?text=${Uri.encodeComponent(mensagem)}',
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
    );
  }
}

// APLICATIVO PRINCIPAL
class MiaudotaApp extends StatelessWidget {
  const MiaudotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Miaudota',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: primaryOrange,
        scaffoldBackgroundColor: lightBeige,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryOrange,
          primary: primaryOrange,
          secondary: primaryOrange,
          background: lightBeige,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          // LABEL cinza sempre que NÃO estiver focado
          labelStyle: const TextStyle(color: Color(0xFF777777), fontSize: 14),

          // 👇 MUITO IMPORTANTE: não colocar floatingLabelStyle aqui
          // floatingLabelStyle: ...  // ❌ NÃO USA

          // BORDA cinza (campo normal, focado ou não, desde que sem erro)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDCDCDC), width: 1),
          ),

          // BORDA laranja (campo focado)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryOrange, width: 1.6),
          ),

          // BORDA vermelha (erro)
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),

          // BORDA vermelha focada (erro + foco)
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.6),
          ),

          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
