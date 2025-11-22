import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'forgot_password_page.dart';

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
  String email;
  String telefone;
  String estado;
  String cidade;
  String bairro;

  UserProfile({
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.estado,
    required this.cidade,
    required this.bairro,
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
  String descricao; // texto sobre o pet
  String imagemPath; // caminho da imagem (assets/images/...)
  String telefoneDono; // telefone de quem cadastrou o pet

  PetParaAdocao({
    required this.nome,
    required this.especie,
    required this.raca,
    required this.idade,
    required this.cidade,
    required this.estado,
    required this.descricao,
    required this.imagemPath,
    required this.telefoneDono,
  });

  String get tipo => '$especie $raca';
  String get cidadeEstado => '$cidade – $estado';
}

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

const primaryOrange = Color(0xFFFF8A3C);
const lightBeige = Color(0xFFFFF8E7);

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
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryOrange, width: 1.5),
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/carregamento.png', width: 160),
            const SizedBox(height: 24),
            const Text(
              'Conectando lares a patinhas...',
              style: TextStyle(fontSize: 16, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _entrar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // aqui seria a autenticação real (API, Firebase etc.)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Image.asset('assets/images/logo.png', width: 160),
                      const SizedBox(height: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Entre com a sua conta',
                      style: TextStyle(
                        fontFamily: 'PoetsenOne',
                        fontSize: 18,
                        color: Colors.orange,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // E-MAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Digite seu e-mail*',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe seu e-mail';
                      }
                      if (!value.contains('@')) {
                        return 'Informe um e-mail válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // SENHA
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Digite sua senha*',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe sua senha';
                      }
                      if (value.trim().length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _entrar,
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        fontFamily: 'PoetsenOne',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Esqueceu a senha',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color(0xFF777777),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignupPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryOrange),
                      minimumSize: const Size(double.infinity, 44),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    child: const Text(
                      'Criar nova conta',
                      style: TextStyle(
                        fontFamily: 'PoetsenOne',
                        color: primaryOrange,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  TextButton(
                    style: TextButton.styleFrom(alignment: Alignment.center),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TermsPage()),
                      );
                    },
                    child: const Text(
                      'Termo de uso e\nPolítica de privacidade\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color(0xFF777777),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _senha2Controller = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _senha2Controller.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF777777), fontSize: 14),
      floatingLabelStyle: const TextStyle(
        color: primaryOrange,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCDCDC), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryOrange, width: 1.6),
      ),
    );
  }

  void _criarConta() {
    if (!_formKey.currentState!.validate()) return;

    // Salva os dados no AppState
    AppState.userProfile.nome = _nomeController.text.trim();
    AppState.userProfile.cpf = _cpfController.text.trim();
    AppState.userProfile.email = _emailController.text.trim();
    AppState.userProfile.telefone = _telefoneController.text.trim();
    AppState.userProfile.estado = '';
    AppState.userProfile.cidade = '';
    AppState.userProfile.bairro = '';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFFFE0B5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo.png', height: 64),
                  const Text(
                    'Criar conta',
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: size.height * 0.7),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 4),
                          const Text(
                            'Para realizar o cadastro preencha os dados abaixo:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            ),
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _nomeController,
                            decoration: _fieldDecoration(
                              'Digite seu nome completo*',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Informe seu nome completo'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _cpfController,
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration('Digite seu CPF*'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Informe seu CPF';
                              if (v.replaceAll(RegExp(r'\D'), '').length < 11) {
                                return 'Informe um CPF válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _fieldDecoration('Digite seu e-mail*'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Informe seu e-mail';
                              if (!v.contains('@')) return 'E-mail inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _telefoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _fieldDecoration(
                              'Digite seu número de celular*',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Informe seu telefone'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _senhaController,
                            obscureText: true,
                            decoration: _fieldDecoration('Digite sua senha*'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Informe sua senha';
                              if (v.length < 6)
                                return 'A senha deve ter no mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _senha2Controller,
                            obscureText: true,
                            decoration: _fieldDecoration('Repita sua senha*'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Repita a senha';
                              if (v != _senhaController.text)
                                return 'As senhas não coincidem';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'Ao criar uma conta você aceita os Termos de Uso.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF777777),
                            ),
                          ),
                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: _criarConta,
                            child: const Text(
                              'Criar conta',
                              style: TextStyle(
                                fontFamily: 'PoetsenOne',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: primaryOrange),
                              minimumSize: const Size(double.infinity, 44),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Entrar com a minha conta',
                              style: TextStyle(
                                color: primaryOrange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _petIndex = 0;
  // lista de pets exibidos na Home (já filtrados)
  List<PetParaAdocao> _petsFiltrados = [];

  // filtros atuais
  String? _filtroEspecie;
  String? _filtroRaca;
  String? _filtroCidade;
  String? _filtroEstado;

  // controllers para os campos do popup de filtros
  final TextEditingController _filtroEspecieController =
      TextEditingController();
  final TextEditingController _filtroRacaController = TextEditingController();
  final TextEditingController _filtroCidadeController = TextEditingController();

  InputDecoration _filtroDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      // texto quando não focado
      labelStyle: const TextStyle(color: Color(0xFF777777), fontSize: 14),

      // texto quando focado
      floatingLabelStyle: const TextStyle(
        color: primaryOrange,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),

      // borda quando NÃO focado (cinza)
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),

      // borda quando focado (laranja)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 1.6),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // começa mostrando todos os pets cadastrados
    _petsFiltrados = List.from(AppState.petsParaAdocao);

    // popup de solicitação pendente (continua igual)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarSolicitacoesPendentes();
    });
  }

  void _verificarSolicitacoesPendentes() {
    if (AppState.solicitacoesPendentes.isEmpty) return;

    final solicitacao = AppState.solicitacoesPendentes.first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Center(
          child: Text(
            'Nova solicitação de adoção',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        content: Text(
          '${solicitacao.nomeInteressado} quer adotar ${solicitacao.pet.nome}.',
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8, top: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFFE5E5),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              AppState.solicitacoesPendentes.remove(solicitacao);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text(
              'Recusar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              solicitacao.aprovado = true;

              // remove da lista de para adoção
              AppState.petsParaAdocao.removeWhere(
                (p) => p.nome == solicitacao.pet.nome,
              );

              // marca como aprovado em "pets adotados"
              for (final p in AppState.petsAdotados) {
                if (p.nome == solicitacao.pet.nome) {
                  p.aprovado = true;
                }
              }

              AppState.solicitacoesPendentes.remove(solicitacao);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text(
              'Aprovar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _aplicarFiltros() {
    setState(() {
      _petsFiltrados = AppState.petsParaAdocao.where((pet) {
        final matchEspecie =
            _filtroEspecie == null ||
            _filtroEspecie!.isEmpty ||
            pet.especie.toLowerCase().contains(_filtroEspecie!.toLowerCase());

        final matchRaca =
            _filtroRaca == null ||
            _filtroRaca!.isEmpty ||
            pet.raca.toLowerCase().contains(_filtroRaca!.toLowerCase());

        final matchCidade =
            _filtroCidade == null ||
            _filtroCidade!.isEmpty ||
            pet.cidade.toLowerCase().contains(_filtroCidade!.toLowerCase());

        final matchEstado =
            _filtroEstado == null ||
            _filtroEstado!.isEmpty ||
            pet.estado.toLowerCase() == _filtroEstado!.toLowerCase();

        return matchEspecie && matchRaca && matchCidade && matchEstado;
      }).toList();

      _petIndex = 0; // reinicia ao aplicar filtros
    });
  }

  void _abrirFiltros() {
    // preenche com os valores atuais dos filtros
    _filtroEspecieController.text = _filtroEspecie ?? '';
    _filtroRacaController.text = _filtroRaca ?? '';
    _filtroCidadeController.text = _filtroCidade ?? '';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          insetPadding: const EdgeInsets.fromLTRB(16, 60, 16, 220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Filtros de busca',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PoetsenOne',
              fontSize: 16,
              color: Color(0xFF1D274A),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Refine a busca pelos pets disponíveis para adoção:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF777777)),
                ),
                const SizedBox(height: 16),

                // ESPÉCIE
                TextFormField(
                  controller: _filtroEspecieController,
                  decoration: _filtroDecoration('Espécie (ex: Gato, Cachorro)'),
                ),
                const SizedBox(height: 12),

                // RAÇA
                TextFormField(
                  controller: _filtroRacaController,
                  decoration: _filtroDecoration('Raça (ex: SRD, Siamês)'),
                ),
                const SizedBox(height: 12),

                // CIDADE
                TextFormField(
                  controller: _filtroCidadeController,
                  decoration: _filtroDecoration('Cidade'),
                ),
                const SizedBox(height: 12),

                // ESTADO
                DropdownButtonFormField<String>(
                  value: _filtroEstado,
                  decoration: _filtroDecoration('Estado'),
                  items: estadosBrasil
                      .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _filtroEstado = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            Row(
              children: [
                // Botão LIMPAR (à esquerda)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _filtroEspecieController.clear();
                        _filtroRacaController.clear();
                        _filtroCidadeController.clear();

                        _filtroEspecie = '';
                        _filtroRaca = '';
                        _filtroCidade = '';
                        _filtroEstado = null;

                        _aplicarFiltros();
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9F9F9),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Limpar filtros',
                      style: TextStyle(color: Color(0xFF1D274A)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botão APLICAR (à direita)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filtroEspecie = _filtroEspecieController.text.trim();
                        _filtroRaca = _filtroRacaController.text.trim();
                        _filtroCidade = _filtroCidadeController.text.trim();
                        _aplicarFiltros();
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _filtroEspecieController.dispose();
    _filtroRacaController.dispose();
    _filtroCidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = _petsFiltrados.isNotEmpty ? _petsFiltrados[_petIndex] : null;

    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: const Color(0xFFFFE0B5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo.png', height: 64),
                  OutlinedButton.icon(
                    onPressed: _abrirFiltros, // 👈 sem parâmetro
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryOrange),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(
                      Icons.tune,
                      size: 16,
                      color: primaryOrange,
                    ),
                    label: const Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: _petsFiltrados.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Nenhum pet encontrado com os filtros atuais.\n\n'
                          'Ajuste os filtros para ver outros pets disponíveis 🐾',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                  child: Image.asset(
                                    pet!.imagemPath,
                                    fit: BoxFit.cover,
                                    height: 450,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 42,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            pet.nome,
                                            style: const TextStyle(
                                              fontFamily: 'PoetsenOne',
                                              fontSize: 20,
                                              color: Color(0xFF1D274A),
                                            ),
                                          ),
                                          Text(
                                            '${pet.cidade} – ${pet.estado}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Color(0xFF1D274A),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${pet.especie} • ${pet.idade}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Botões
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _petIndex++;
                                                  if (_petIndex >=
                                                      _petsFiltrados.length) {
                                                    _petIndex =
                                                        0; // reinicia para o primeiro quando chega no final
                                                  }
                                                });
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Color(0xFFCCCCCC),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                backgroundColor: const Color(
                                                  0xFFF9F9F9,
                                                ),
                                              ),
                                              child: const Text(
                                                'Próximo',
                                                style: TextStyle(
                                                  fontFamily: 'PoetsenOne',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  color: Color(0xFF1D274A),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        AdoptionPage(pet: pet),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryOrange,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'Ver detalhes',
                                                style: TextStyle(
                                                  fontFamily: 'PoetsenOne',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '1 de ${_petsFiltrados.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),

      // BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: primaryOrange,
        unselectedItemColor: const Color(0xFF999999),
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 1) {
            if (AppState.petsParaAdocao.isNotEmpty) {
              final firstPet = AppState.petsParaAdocao.first;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AdoptionPage(pet: firstPet)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Color(0xFF1D274A),
                  content: Text(
                    'Nenhum pet disponível para adoção no momento.',
                    style: const TextStyle(
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TipsPage()),
            );
          } else if (index == 3) {
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
      ),
    );
  }
}

class AdoptionPage extends StatefulWidget {
  final PetParaAdocao pet;

  const AdoptionPage({super.key, required this.pet});

  @override
  State<AdoptionPage> createState() => _AdoptionPageState();
}

class _AdoptionPageState extends State<AdoptionPage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();

    // Descobre em qual posição da lista está o pet recebido
    final i = AppState.petsParaAdocao.indexWhere(
      (p) => p.nome == widget.pet.nome,
    );

    _index = i == -1 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    if (AppState.petsParaAdocao.isEmpty) {
      return Scaffold(
        backgroundColor: lightBeige,
        body: const Center(
          child: Text('Nenhum pet disponível para adoção no momento.'),
        ),
      );
    }

    final pet = AppState.petsParaAdocao[_index];

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
                    'Adoção',
                    style: TextStyle(
                      fontFamily: 'PoetsenOne',
                      fontSize: 18,
                      color: Color(0xFF1D274A),
                    ),
                  ),
                ],
              ),
            ),

            // CONTEÚDO
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        child: Image.asset(
                          pet.imagemPath,
                          fit: BoxFit.cover,
                          height: 350,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nome + cidade
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  pet.nome,
                                  style: const TextStyle(
                                    fontFamily: 'PoetsenOne',
                                    fontSize: 20,
                                    color: Color(0xFF1D274A),
                                  ),
                                ),
                                Text(
                                  pet.cidadeEstado,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF1D274A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pet.tipo} • ${pet.idade.isEmpty ? 'Idade não informada' : pet.idade}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              pet.descricao.isEmpty
                                  ? 'Este pet está esperando um lar cheio de carinho. 💛'
                                  : pet.descricao,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Cidade / Estado',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF1D274A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pet.cidadeEstado,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(height: 12),

                            const Text(
                              'Contato',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF1D274A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // telefone + WhatsApp
                            Row(
                              children: [
                                Text(
                                  pet.telefoneDono.isEmpty
                                      ? '(00) 00000-0000'
                                      : pet.telefoneDono,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    final numero = pet.telefoneDono.isEmpty
                                        ? '550000000000'
                                        : pet.telefoneDono.replaceAll(
                                            RegExp(r'\D'),
                                            '',
                                          );
                                    abrirWhatsApp(
                                      context,
                                      numeroComDDD: numero,
                                      mensagem:
                                          'Olá! Tenho interesse em adotar ${pet.nome} 🐾',
                                    );
                                  },
                                  child: const FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Botões: Cancelar / Adotar
                            Row(
                              children: [
                                // BOTÃO CANCELAR
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        AppState.petsParaAdocao.removeAt(
                                          _index,
                                        );

                                        // se acabou a lista de pets, voltar para a tela anterior
                                        if (AppState.petsParaAdocao.isEmpty) {
                                          Navigator.pop(context);
                                          return;
                                        }

                                        // ajusta o índice se necessário
                                        if (_index >=
                                            AppState.petsParaAdocao.length) {
                                          _index = 0;
                                        }
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFCCCCCC),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: const Color(0xFFF9F9F9),
                                    ),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(
                                        fontFamily: 'PoetsenOne',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Color(0xFF1D274A),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // BOTÃO ADOTAR
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final profile = AppState.userProfile;

                                      if (profile.nome.isEmpty ||
                                          profile.email.isEmpty ||
                                          profile.telefone.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Complete seus dados de perfil antes de solicitar a adoção. 💛',
                                            ),
                                          ),
                                        );

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const EditProfilePage(),
                                          ),
                                        );
                                        return;
                                      }

                                      final pet =
                                          AppState.petsParaAdocao[_index];

                                      final solicitacao = SolicitacaoAdocao(
                                        pet: pet,
                                        nomeInteressado: profile.nome,
                                        telefoneInteressado: profile.telefone,
                                        emailInteressado: profile.email,
                                        aprovado: false,
                                      );

                                      AppState.solicitacoesPendentes.add(
                                        solicitacao,
                                      );

                                      final jaExiste = AppState.petsAdotados
                                          .any((p) => p.nome == pet.nome);

                                      if (!jaExiste) {
                                        AppState.petsAdotados.add(
                                          PetAdotado(
                                            nome: pet.nome,
                                            tipo: pet.tipo,
                                            aprovado: false,
                                            reprovado: false,
                                          ),
                                        );
                                      }

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Color(0xFF1D274A),
                                          content: Text(
                                            'Solicitação de adoção enviada para ${pet.nome}.',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          margin: const EdgeInsets.all(12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ), // bordas arredondadas
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryOrange,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Adotar',
                                      style: TextStyle(
                                        fontFamily: 'PoetsenOne',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                '${_index + 1} de ${AppState.petsParaAdocao.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF777777),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: primaryOrange,
        unselectedItemColor: const Color(0xFF999999),
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TipsPage()),
            );
          } else if (index == 3) {
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
      ),
    );
  }
}

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
                          fontSize: 13,
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

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor: primaryOrange,
        unselectedItemColor: const Color(0xFF999999),
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 1) {
            if (AppState.petsParaAdocao.isNotEmpty) {
              final pet = AppState.petsParaAdocao.first;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AdoptionPage(pet: pet)),
              );
            }
          } else if (index == 3) {
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
      ),
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
            style: TextStyle(fontSize: 13, color: Color(0xFF1D274A)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
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
                    'Cuidado e Afeto',
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
                        fontSize: 13,
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
                      style: TextStyle(fontSize: 13, height: 1.5),
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
                      style: TextStyle(fontSize: 13, height: 1.5),
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
                      style: TextStyle(fontSize: 13, height: 1.5),
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

      bottomNavigationBar: _tipsBottomNav(context),
    );
  }
}

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
            style: TextStyle(fontSize: 13, color: Color(0xFF1D274A)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
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
                      style: TextStyle(fontSize: 13, height: 1.5),
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
      bottomNavigationBar: _tipsBottomNav(context),
    );
  }
}

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
            style: TextStyle(fontSize: 13, color: Color(0xFF1D274A)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
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
                      style: TextStyle(fontSize: 13, height: 1.5),
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
      bottomNavigationBar: _tipsBottomNav(context),
    );
  }
}

Widget _tipsBottomNav(BuildContext context) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    currentIndex: 2, // 0=Home, 1=Adotar, 2=Dicas, 3=Perfil
    selectedItemColor: primaryOrange,
    unselectedItemColor: const Color(0xFF999999),
    showUnselectedLabels: true,
    onTap: (index) {
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else if (index == 1) {
        if (AppState.petsParaAdocao.isNotEmpty) {
          final pet = AppState.petsParaAdocao.first;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdoptionPage(pet: pet)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum pet disponível para adoção.')),
          );
        }
      } else if (index == 2) {
        // Volta para a página inicial das dicas
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TipsPage()),
        );
      } else if (index == 3) {
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  /// Abre o popup de solicitação para UM pet específico
  void _abrirSolicitacoesParaPet(PetParaAdocao pet) {
    // pega apenas as solicitações pendentes desse pet
    final pendentes = AppState.solicitacoesPendentes
        .where((s) => s.pet.nome == pet.nome && !s.aprovado)
        .toList();

    if (pendentes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há solicitações de adoção para este pet.'),
        ),
      );
      return;
    }

    final solicitacao = pendentes.first;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Solicitação de adoção',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            '${solicitacao.nomeInteressado} quer adotar ${solicitacao.pet.nome}.',
            textAlign: TextAlign.center,
          ),
          actionsPadding: const EdgeInsets.only(
            bottom: 12,
            right: 12,
            left: 12,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE5E5),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _recusarSolicitacao(solicitacao);
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Recusar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _aprovarSolicitacao(solicitacao);
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Aprovar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Abre o popup de solicitação para TODOS os pets
  void _recusarSolicitacao(SolicitacaoAdocao s) {
    // Marca como reprovado na lista de pets adotados (se existir)
    final index = AppState.petsAdotados.indexWhere((p) => p.nome == s.pet.nome);

    if (index != -1) {
      AppState.petsAdotados[index].aprovado = false;
      AppState.petsAdotados[index].reprovado = true;
    }

    // Remove a solicitação da lista de pendentes
    AppState.solicitacoesPendentes.remove(s);

    setState(() {});
  }

  void _aprovarSolicitacao(SolicitacaoAdocao s) {
    s.aprovado = true;

    // remove o pet da lista de "para adoção"
    AppState.petsParaAdocao.removeWhere((p) => p.nome == s.pet.nome);

    // adiciona/atualiza como aprovado na lista de pets adotados
    final adotado = AppState.petsAdotados.firstWhere(
      (p) => p.nome == s.pet.nome,
      orElse: () {
        final novo = PetAdotado(
          nome: s.pet.nome,
          tipo: s.pet.tipo,
          aprovado: true,
          reprovado: false,
        );
        AppState.petsAdotados.add(novo);
        return novo;
      },
    );

    adotado.aprovado = true;
    adotado.reprovado = false;

    // remove a solicitação da fila
    AppState.solicitacoesPendentes.remove(s);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppState.userProfile;

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
                    'Meu perfil',
                    style: TextStyle(
                      fontFamily: 'PoetsenOne',
                      fontSize: 18,
                      color: Color(0xFF1D274A),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),

            // conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card de dados da pessoa
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 28,
                                backgroundColor: Color(0xFFFFE0B5),
                                child: Icon(
                                  Icons.person,
                                  color: primaryOrange,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  profile.nome.isEmpty
                                      ? 'Seu nome'
                                      : profile.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Color(0xFF1D274A),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 22),
                                color: const Color(0xFF1D274A),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfilePage(),
                                    ),
                                  );
                                  setState(() {});
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          // campos CPF, email, telefone, bairro, cidade/estado
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'CPF\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: profile.cpf.isEmpty ? '—' : profile.cpf,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'E-mail\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: profile.email.isEmpty
                                      ? '—'
                                      : profile.email,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Telefone\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: profile.telefone.isEmpty
                                      ? '—'
                                      : profile.telefone,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Estado\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: profile.estado.isEmpty
                                      ? '—'
                                      : profile.estado,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Cidade\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: profile.cidade.isEmpty
                                      ? '—'
                                      : profile.cidade,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF1D274A),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Bairro\n',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: profile.bairro.isEmpty
                                      ? '—'
                                      : profile.bairro,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // PETS QUE ADOTOU
                    Row(
                      children: const [
                        Icon(Icons.favorite, color: primaryOrange),
                        SizedBox(width: 8),
                        Text(
                          'Pets que adotou',
                          style: TextStyle(
                            fontFamily: 'PoetsenOne',
                            fontSize: 16,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (AppState.petsAdotados.isEmpty)
                      const Text(
                        'Você ainda não adotou nenhum pet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF777777),
                        ),
                      )
                    else
                      Column(
                        children: AppState.petsAdotados.map((pet) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.nome,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: Color(0xFF1D274A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        pet.tipo,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        pet.reprovado
                                            ? 'Adoção reprovada'
                                            : (pet.aprovado
                                                  ? 'Adoção aprovada'
                                                  : 'Aguardando aprovação'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: pet.reprovado
                                              ? Colors.red
                                              : (pet.aprovado
                                                    ? Colors.green
                                                    : const Color.fromARGB(
                                                        255,
                                                        255,
                                                        138,
                                                        60,
                                                      )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!pet.aprovado)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        AppState.petsAdotados.remove(pet);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                Icon(
                                  Icons.favorite,
                                  color: pet.aprovado
                                      ? primaryOrange
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 24),

                    // PETS PARA ADOÇÃO
                    Row(
                      children: const [
                        Icon(Icons.pets, color: primaryOrange),
                        SizedBox(width: 8),
                        Text(
                          'Pets para adoção',
                          style: TextStyle(
                            fontFamily: 'PoetsenOne',
                            fontSize: 16,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (AppState.petsParaAdocao.isEmpty)
                      const Text(
                        'Você ainda não adicionou nenhum pet para adoção.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF777777),
                        ),
                      )
                    else
                      Column(
                        children: AppState.petsParaAdocao.map((pet) {
                          final pendentesDoPet = AppState.solicitacoesPendentes
                              .where(
                                (s) => s.pet.nome == pet.nome && !s.aprovado,
                              )
                              .toList();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.nome,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF1D274A),
                                        ),
                                      ),
                                      Text(
                                        pet.tipo,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF777777),
                                        ),
                                      ),
                                      if (pendentesDoPet.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          '${pendentesDoPet.length} solicitação(ões) pendente(s)',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                if (pendentesDoPet.isEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: Color(0xFF1D274A),
                                        ),
                                        onPressed: () async {
                                          final updated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PetPage(pet: pet),
                                            ),
                                          );

                                          if (updated == true) {
                                            setState(
                                              () {},
                                            ); // atualiza a tela com os dados editados
                                          }
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            AppState.petsParaAdocao.remove(pet);
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  TextButton(
                                    onPressed: () {
                                      _abrirSolicitacoesParaPet(pet);
                                    },
                                    child: const Text(
                                      'Ver solicitações',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primaryOrange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    TextButton.icon(
                      onPressed: () async {
                        if (!isUserProfileComplete()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Complete seus dados de perfil (nome, CPF, e-mail, telefone, cidade, estado e bairro) antes de cadastrar um pet para adoção.',
                              ),
                            ),
                          );

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          );

                          setState(
                            () {},
                          ); // atualiza depois que voltar do editar perfil
                          return;
                        }

                        // se cadastro está completo, segue para a tela de PetPage / NewPetPage
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PetPage()),
                        );
                        setState(() {});
                      },
                      icon: const Icon(Icons.add, color: primaryOrange),
                      label: const Text(
                        'Adicionar novo pet para adoção',
                        style: TextStyle(color: primaryOrange),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SAIR DA CONTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEEEEE),
                          foregroundColor: const Color(0xFF1D274A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Sair da conta',
                          style: TextStyle(
                            fontFamily: 'PoetsenOne',
                            fontSize: 16,
                            color: Color(0xFF1D274A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        selectedItemColor: primaryOrange,
        unselectedItemColor: const Color(0xFF999999),
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 1) {
            if (AppState.petsParaAdocao.isNotEmpty) {
              final pet = AppState.petsParaAdocao.first;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AdoptionPage(pet: pet)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Nenhum pet disponível para adoção no momento.',
                  ),
                ),
              );
            }
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TipsPage()),
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
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _cpfController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _cidadeController;
  late TextEditingController _bairroController;

  String? _estadoSelecionado; // Guarda o UF escolhido

  @override
  void initState() {
    super.initState();
    final p = AppState.userProfile;

    _nomeController = TextEditingController(text: p.nome);
    _cpfController = TextEditingController(text: p.cpf);
    _emailController = TextEditingController(text: p.email);
    _telefoneController = TextEditingController(text: p.telefone);
    _cidadeController = TextEditingController(text: p.cidade);
    _bairroController = TextEditingController(text: p.bairro);

    _estadoSelecionado = p.estado.isNotEmpty ? p.estado : null;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 1.4),
      ),
      labelStyle: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 14),
      floatingLabelStyle: const TextStyle(color: primaryOrange, fontSize: 13),
    );
  }

  void _salvarPerfil() {
    if (!_formKey.currentState!.validate()) {
      // Mensagem geral
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
      );
      return;
    }
    AppState.userProfile.nome = _nomeController.text.trim();
    AppState.userProfile.cpf = _cpfController.text.trim();
    AppState.userProfile.email = _emailController.text.trim();
    AppState.userProfile.telefone = _telefoneController.text.trim();
    AppState.userProfile.estado = _estadoSelecionado ?? '';
    AppState.userProfile.cidade = _cidadeController.text.trim();
    AppState.userProfile.bairro = _bairroController.text.trim();

    Navigator.pop(context); // volta para Meu perfil
  }

  void _excluirConta() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Excluir conta',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: const Text('Tem certeza que deseja excluir seu cadastro?'),
          actionsPadding: const EdgeInsets.only(right: 12, bottom: 8, top: 8),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE7EBF7),
                foregroundColor: const Color(0xFF1D274A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFE5E5),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                AppState.userProfile = UserProfile(
                  nome: '',
                  cpf: '',
                  email: '',
                  telefone: '',
                  estado: '',
                  cidade: '',
                  bairro: '',
                );
                AppState.petsAdotados.clear();
                AppState.petsParaAdocao.clear();

                Navigator.pop(ctx);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text(
                'Excluir',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
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
                    'Editar perfil',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        const Text(
                          'Atualize seus dados de cadastro:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF777777),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // NOME
                        TextFormField(
                          controller: _nomeController,
                          decoration: _inputDecoration(
                            'Digite seu nome completo*',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu nome completo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // CPF
                        TextFormField(
                          controller: _cpfController,
                          decoration: _inputDecoration('Digite seu CPF*'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu CPF';
                            }
                            if (value.replaceAll(RegExp(r'\D'), '').length <
                                11) {
                              return 'Informe um CPF válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // E-MAIL
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration('Digite seu e-mail*'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu e-mail';
                            }
                            if (!value.contains('@')) {
                              return 'Informe um e-mail válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // TELEFONE
                        TextFormField(
                          controller: _telefoneController,
                          decoration: _inputDecoration('Digite seu telefone*'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu telefone';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // ESTADO (Dropdown obrigatório)
                        DropdownButtonFormField<String>(
                          value: _estadoSelecionado,
                          decoration: _inputDecoration('Estado*'),
                          items: estadosBrasil.map((uf) {
                            return DropdownMenuItem(value: uf, child: Text(uf));
                          }).toList(),
                          onChanged: (uf) {
                            setState(() {
                              _estadoSelecionado = uf;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione um estado';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // CIDADE
                        TextFormField(
                          controller: _cidadeController,
                          decoration: _inputDecoration('Cidade*'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a cidade';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // BAIRRO
                        TextFormField(
                          controller: _bairroController,
                          decoration: _inputDecoration('Bairro*'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o bairro';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _salvarPerfil,
                          child: const Text(
                            'Salvar',
                            style: TextStyle(
                              fontFamily: 'PoetsenOne',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFE5E5),
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _excluirConta,
                            child: const Text(
                              'Excluir conta',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class PetPage extends StatefulWidget {
  final PetParaAdocao? pet; // null = novo pet, não null = editar

  const PetPage({super.key, this.pet});

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _especieController;
  late TextEditingController _racaController;
  late TextEditingController _idadeController;
  late TextEditingController _cidadeEstadoController;
  late TextEditingController _descricaoController;
  late TextEditingController _imagemController;

  @override
  void initState() {
    super.initState();

    final p = widget.pet; // pet vindo da tela

    if (p != null) {
      // MODO EDITAR
      _nomeController = TextEditingController(text: p.nome);
      _especieController = TextEditingController(text: p.especie);
      _racaController = TextEditingController(text: p.raca);
      _idadeController = TextEditingController(text: p.idade);
      _descricaoController = TextEditingController(text: p.descricao);
      _imagemController = TextEditingController(text: p.imagemPath);
      _cidadeEstadoController = TextEditingController(
        text: '${p.cidade} – ${p.estado}',
      );
    } else {
      // MODO NOVO PET
      final profile = AppState.userProfile;

      _nomeController = TextEditingController();
      _especieController = TextEditingController();
      _racaController = TextEditingController();
      _idadeController = TextEditingController();
      _descricaoController = TextEditingController();
      _imagemController = TextEditingController(text: 'assets/images/tom.png');

      if (profile.cidade.isNotEmpty && profile.estado.isNotEmpty) {
        _cidadeEstadoController = TextEditingController(
          text: '${profile.cidade} – ${profile.estado}',
        );
      } else {
        _cidadeEstadoController = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _especieController.dispose();
    _racaController.dispose();
    _idadeController.dispose();
    _cidadeEstadoController.dispose();
    _descricaoController.dispose();
    _imagemController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 1.4),
      ),
      labelStyle: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 14),
      floatingLabelStyle: const TextStyle(color: primaryOrange, fontSize: 13),
    );
  }

  void _salvar() {
    // garante que o usuário está com cadastro completo
    if (!isUserProfileComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete seu cadastro antes de salvar um pet para adoção.',
          ),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfilePage()),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // se for novo pet
    final perfil = AppState.userProfile;
    final newPet = PetParaAdocao(
      nome: _nomeController.text.trim(),
      especie: _especieController.text.trim(),
      raca: _racaController.text.trim(),
      idade: _idadeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      cidade: perfil.cidade,
      estado: perfil.estado,
      imagemPath: _imagemController.text.trim(),
      telefoneDono: perfil.telefone,
    );

    AppState.petsParaAdocao.add(newPet);
    Navigator.pop(context, true);
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
                    'Editar pet',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Atualize as informações do pet:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF777777),
                          ),
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Seleção de foto pode ser implementada depois '
                                  'com o plugin image_picker. No momento use um caminho de asset.',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.photo_camera_outlined,
                                  size: 32,
                                  color: Color(0xFFB3B3B3),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Adicionar foto (placeholder)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _imagemController,
                          decoration: _inputDecoration(
                            'Caminho da imagem (ex: assets/images/tom.png)',
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nomeController,
                          decoration: _inputDecoration(
                            'Nome do pet* (ex: Tom)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome do pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _especieController,
                          decoration: _inputDecoration(
                            'Espécie* (ex: Gato, Cachorro)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a espécie do pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _racaController,
                          decoration: _inputDecoration(
                            'Raça* (ex: SRD, Siamês)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a raça do pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _idadeController,
                          decoration: _inputDecoration(
                            'Idade* (ex: 2 anos, 4 meses)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a idade do pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _descricaoController,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            'Descrição do pet* (temperamento, cuidados, etc.)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Descreva um pouco sobre o pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            // BOTÃO CANCELAR
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  ); // apenas sai sem salvar
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFCCCCCC),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: const Color(0xFFF9F9F9),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontFamily: 'PoetsenOne',
                                    fontSize: 16,
                                    color: Color(0xFF1D274A),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // BOTÃO SALVAR ALTERAÇÕES
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _salvar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryOrange,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Salvar',
                                  style: TextStyle(
                                    fontFamily: 'PoetsenOne',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            // Barra Superior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFFFE0B5),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset('assets/images/logo.png', height: 64),
                  ),

                  const Text(
                    'Termo de uso e\nPolítica de privacidade',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PoetsenOne',
                      fontSize: 18,
                      color: Color(0xFF1D274A),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF1D274A),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
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

                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
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
                              fontWeight: FontWeight.bold,
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

                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
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
                              fontWeight: FontWeight.bold,
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
