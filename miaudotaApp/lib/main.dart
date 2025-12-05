import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'splash_page.dart';
import 'package:miaudota_app/theme/colors.dart';
import 'package:miaudota_app/gateways/auth_gateway.dart';
import 'package:miaudota_app/services/auth_service.dart';

// ====================== MODELOS BÁSICOS ======================

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
    this.isPessoaJuridica = false,
    this.email = '',
    this.telefone = '',
    this.estado = '',
    this.cidade = '',
    this.bairro = '',
  });
}

// Verifica se o perfil está completo (agora considerando PF/PJ)
bool isUserProfileComplete() {
  final p = AppState.userProfile;

  final temDocumento = p.isPessoaJuridica
      ? p.cnpj.trim().isNotEmpty
      : p.cpf.trim().isNotEmpty;

  return p.nome.trim().isNotEmpty &&
      temDocumento &&
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

// ====================== PetParaAdocao (ÚNICA VERSÃO) ======================

class PetParaAdocao {
  int? id;
  String nome;
  String tipo; // já existe no seu modelo
  String especie;
  String raca;
  String idade;
  String descricao;
  String cidade;
  String estado;
  String bairro;
  String imagemPath;
  String telefoneTutor;

  int? usuarioId; // 👈 NOVO: id do usuário dono do pet

  PetParaAdocao({
    this.id,
    required this.nome,
    required this.tipo,
    required this.especie,
    required this.raca,
    required this.idade,
    required this.descricao,
    required this.cidade,
    required this.estado,
    required this.bairro,
    required this.imagemPath,
    required this.telefoneTutor,
    this.usuarioId, // 👈 novo
  });

  //String get tipo => '$especie $raca';
  //String get cidadeEstado => '$cidade – $estado';
}

// ====================== ESTADO GLOBAL ======================

class AppState {
  static UserProfile userProfile = UserProfile(
    nome: '',
    cpf: '',
    cnpj: '',
    isPessoaJuridica: false,
    email: '',
    telefone: '',
    estado: '',
    cidade: '',
    bairro: '',
  );

  static final List<PetAdotado> petsAdotados = [];
  static final List<PetParaAdocao> petsParaAdocao = [];
  static final List<SolicitacaoAdocao> solicitacoesPendentes = [];

  static AuthGateway? authGateway;

  static void atualizarPerfilAPartirDoJson(Map<String, dynamic> json) {
    userProfile = UserProfile(
      nome: json['nome'] ?? '',
      cpf: json['cpf'] ?? '',
      cnpj: json['cnpj'] ?? '',
      isPessoaJuridica: json['isPessoaJuridica'] ?? false,
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      estado: json['estado'] ?? '',
      cidade: json['cidade'] ?? '',
      bairro: json['bairro'] ?? '',
    );
  }

  static Future<void> carregarUsuarioSalvo() async {
    final usuario = await AuthService.getUsuarioLocal();
    if (usuario != null) {
      atualizarPerfilAPartirDoJson(usuario);
    }
  }
}

// ====================== HELPERS ======================

String formatCidadeEstado({String? cidade, String? estado}) {
  final c = (cidade ?? '').trim();
  final e = (estado ?? '').trim();

  if (c.isEmpty && e.isEmpty) {
    return 'Localização não informada';
  }
  if (c.isEmpty) return e;
  if (e.isEmpty) return c;
  return '$c – $e';
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

// ====================== MAIN / APP ======================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppState.carregarUsuarioSalvo();

  runApp(const MiaudotaApp());
}

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
          labelStyle: const TextStyle(color: Color(0xFF777777), fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDCDCDC), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryOrange, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
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
