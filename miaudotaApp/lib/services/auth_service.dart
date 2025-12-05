import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:miaudota_app/main.dart';
// Certifique-se de que a classe UserProfile está acessível aqui,
// se não estiver em main.dart, importe o arquivo correto.

class AuthService {
  // URL da API hospedada no Render
  static const String baseUrl = 'https://faculdade-gvxs.onrender.com';

  /// Função auxiliar para carregar o perfil do SharedPreferences de forma segura
  static Future<Map<String, dynamic>> _loadLocalProfile(
    SharedPreferences prefs,
  ) async {
    Map<String, dynamic> usuarioLocal = {};
    final jsonLocal = prefs.getString('usuario');
    if (jsonLocal != null) {
      try {
        usuarioLocal = Map<String, dynamic>.from(jsonDecode(jsonLocal));
      } catch (_) {
        // Ignora erro de parse se o JSON estiver corrompido
      }
    }
    return usuarioLocal;
  }

  // --- MÉTODOS DE AUTENTICAÇÃO E PERFIL ---

  /// LOGIN
  static Future<void> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    print('LOGIN status: ${response.statusCode}');
    print('LOGIN body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final usuarioServidor = Map<String, dynamic>.from(data['usuario'] ?? {});

      final userId = usuarioServidor['id']?.toString();
      if (userId == null) {
        throw Exception('Resposta do servidor incompleta (ID não encontrado)');
      }

      final prefs = await SharedPreferences.getInstance();

      // 1. Tenta carregar os dados COMPLETOS salvos localmente (CPF, Endereço, Telefone)
      Map<String, dynamic> usuarioLocal = await _loadLocalProfile(prefs);

      // 2. Mescla: dados do servidor (id, nome, email, etc.) SOBREPÕEM os locais.
      // Dados locais não retornados pelo servidor (como endereço) são preservados.
      final usuarioCompletinho = <String, dynamic>{
        ...usuarioLocal,
        ...usuarioServidor,
        // Garante que o ID do servidor seja usado
        'id': userId,
        'email': usuarioServidor['email'] ?? usuarioLocal['email'] ?? email,
      };

      // 3. Garante que todos os campos complementares existam com valor padrão se ainda estiverem ausentes.
      usuarioCompletinho.putIfAbsent('cpf', () => '');
      usuarioCompletinho.putIfAbsent('cnpj', () => '');
      usuarioCompletinho.putIfAbsent(
        'isPessoaJuridica',
        () => usuarioLocal['isPessoaJuridica'] ?? false,
      );
      usuarioCompletinho.putIfAbsent('telefone', () => '');
      usuarioCompletinho.putIfAbsent('estado', () => '');
      usuarioCompletinho.putIfAbsent('cidade', () => '');
      usuarioCompletinho.putIfAbsent('bairro', () => '');

      print('SALVOU USUARIO LOCAL: ${jsonEncode(usuarioCompletinho)}');

      // 4. Salva no SharedPreferences
      await prefs.setString('usuario', jsonEncode(usuarioCompletinho));
      await prefs.setString('user_id', userId);

      if (data['token'] != null) {
        await prefs.setString('token', data['token']);
      }

      // 5. Atualiza o AppState a partir do JSON COMPLETO (agora com CPF e Endereço)
      AppState.atualizarPerfilAPartirDoJson(usuarioCompletinho);

      return;
    }

    // Tratamento de erro
    String message;
    try {
      final body = jsonDecode(response.body);
      message = body['error'] ?? body['message'] ?? 'Erro ao fazer login';
    } catch (_) {
      message = 'Erro ${response.statusCode}: ${response.reasonPhrase}';
    }
    throw Exception(message);
  }

  /// CADASTRO
  static Future<void> signup({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    String? cpf,
    String? cnpj,
    required bool isPessoaJuridica,
  }) async {
    // Monta o body que será enviado para a API
    final body = <String, dynamic>{
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'senha': senha,
      'isPessoaJuridica': isPessoaJuridica,
    };

    // Só envia o documento que estiver preenchido
    if (cpf != null && cpf.isNotEmpty) {
      body['cpf'] = cpf;
    }
    if (cnpj != null && cnpj.isNotEmpty) {
      body['cnpj'] = cnpj;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final prefs = await SharedPreferences.getInstance();

      int? idFromApi;
      String? token;

      try {
        final data = jsonDecode(response.body);

        if (data['usuario'] != null) {
          final u = data['usuario'];
          if (u is Map && u['id'] != null) {
            idFromApi = u['id'] is int
                ? u['id'] as int
                : int.tryParse(u['id'].toString());
          }
        }

        if (data['token'] != null) {
          token = data['token'];
        }
      } catch (_) {
        // Se der erro no parse, seguimos só com os dados do formulário
      }

      // Monta o objeto local para SharedPreferences (dados do form + dados vazios complementares)
      final usuarioCompleto = <String, dynamic>{
        'id': idFromApi,
        'nome': nome,
        'cpf': cpf ?? '',
        'cnpj': cnpj ?? '',
        'isPessoaJuridica': isPessoaJuridica,
        'email': email,
        'telefone': telefone,
        'estado': '', // <-- Estes serão preenchidos no updateProfile
        'cidade': '',
        'bairro': '',
      };

      await prefs.setString('usuario', jsonEncode(usuarioCompleto));

      if (idFromApi != null) {
        await prefs.setString('user_id', idFromApi.toString());
      }

      if (token != null) {
        await prefs.setString('token', token);
      }

      AppState.atualizarPerfilAPartirDoJson(usuarioCompleto);
      return;
    }

    String message;
    try {
      final body = jsonDecode(response.body);
      message = body['error'] ?? body['message'] ?? 'Erro ao criar conta';
    } catch (_) {
      message = 'Erro ${response.statusCode}: ${response.reasonPhrase}';
    }

    throw Exception(message);
  }

  /// Atualizar perfil
  static Future<void> updateProfile({
    required String userId,
    required String nome,
    required String cpf,
    required String telefone,
    required String cidade,
    required String estado,
    required String bairro,
    String? cnpj,
    bool isPessoaJuridica = false,
  }) async {
    // Se tiver gateway, delega (uso em testes)
    if (AppState.authGateway != null) {
      return await AppState.authGateway!.updateProfile(
        userId: userId,
        nome: nome,
        cpf: cpf,
        telefone: telefone,
        cidade: cidade,
        estado: estado,
        bairro: bairro,
        cnpj: cnpj,
        isPessoaJuridica: isPessoaJuridica,
      );
    }

    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile/$userId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        // 'userId': userId, // Não é padrão enviar o ID no corpo para PUT
        'nome': nome,
        'cpf': cpf,
        'cnpj': cnpj ?? '',
        'isPessoaJuridica': isPessoaJuridica,
        'telefone': telefone,
        'cidade': cidade,
        'estado': estado,
        'bairro': bairro,
      }),
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      // 1. Carrega o perfil LOCAL ATUAL para preservar dados não enviados (ex: email, token)
      final perfilAtual = await _loadLocalProfile(prefs);

      // 2. Tenta pegar a versão atualizada da API
      Map<String, dynamic> updated;
      try {
        final bodyData = jsonDecode(response.body);
        // O corpo da resposta pode retornar o objeto de usuário completo ou apenas um objeto de confirmação.
        // Tentamos usar o objeto de usuário, se existir.
        if (bodyData['usuario'] != null) {
          updated = Map<String, dynamic>.from(bodyData['usuario']);
        } else {
          updated = bodyData;
        }

        // 3. Mescla: usa o perfil local como base e aplica as atualizações do servidor.
        updated = {...perfilAtual, ...updated};
      } catch (_) {
        // 4. Se a API não retornou o corpo completo (ou se houve erro de parse),
        // montamos o objeto localmente usando os dados enviados + dados que não mudaram.
        updated = {
          ...perfilAtual, // Preserva email, senha, token, etc.
          'id': userId,
          'nome': nome,
          'cpf': cpf,
          'cnpj': cnpj,
          'isPessoaJuridica': isPessoaJuridica,
          'telefone': telefone,
          'cidade': cidade,
          'estado': estado,
          'bairro': bairro,
          // 'email' é mantido via perfilAtual
        };
      }

      // 5. Atualiza AppState e SharedPreferences
      AppState.atualizarPerfilAPartirDoJson(updated);
      await prefs.setString('usuario', jsonEncode(updated));
      return;
    }

    final body = jsonDecode(response.body);
    throw Exception(body['error'] ?? 'Erro ao atualizar perfil');
  }

  // --- MÉTODOS DE RECUPERAÇÃO DE DADOS LOCAIS ---

  /// Usuário logado (JSON bruto)
  static Future<Map<String, dynamic>?> getUsuarioLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('usuario');
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr);
  }

  /// Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ID do usuário (como String)
  static Future<String?> getUserId() async {
    // Se tiver gateway (pra testes/mock), usa ele
    if (AppState.authGateway != null) {
      return await AppState.authGateway!.getUserId();
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // --- MÉTODOS DE AÇÃO ---

  /// Reset de senha via CPF/CNPJ
  static Future<void> resetPassword({
    required String email,
    String? cpf,
    String? cnpj,
    required String novaSenha,
  }) async {
    final body = {'email': email, 'novaSenha': novaSenha};

    if (cpf != null && cpf.isNotEmpty) {
      body['cpf'] = cpf;
    }
    if (cnpj != null && cnpj.isNotEmpty) {
      body['cnpj'] = cnpj;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      try {
        final body = jsonDecode(response.body);
        throw Exception(
          body['error'] ?? body['message'] ?? 'Erro ao redefinir senha',
        );
      } catch (_) {
        throw Exception(
          'Erro ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    }
  }

  /// Logout
  static Future<void> logout() async {
    if (AppState.authGateway != null) {
      return await AppState.authGateway!.logout();
    }
    // Limpa os dados de persistência local
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario'); // Limpa o perfil completo
    await prefs.remove('token');
    await prefs.remove('user_id');
  }

  /// Excluir conta
  static Future<void> deleteAccount(String userId) async {
    if (AppState.authGateway != null) {
      return await AppState.authGateway!.deleteAccount(userId);
    }

    final token = await getToken();
    final url = Uri.parse('$baseUrl/users/$userId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Se excluiu no servidor, limpa tudo localmente
      await logout();
      return;
    }

    try {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Erro ao excluir conta');
    } catch (_) {
      throw Exception('Erro ao excluir conta no servidor.');
    }
  }
}
