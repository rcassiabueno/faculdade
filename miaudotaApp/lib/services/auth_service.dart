import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:miaudota_app/main.dart';
import 'package:miaudota_app/gateways/auth_gateway.dart';

class AuthService {
  // Base URL para a API (emulador Android x desktop)
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  /// LOGIN
  static Future<void> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final usuario = data['usuario'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario', jsonEncode(usuario));

      // ID sempre salvo como STRING
      if (usuario['id'] != null) {
        await prefs.setString('user_id', usuario['id'].toString());
      }

      if (data['token'] != null) {
        await prefs.setString('token', data['token']);
      }

      AppState.atualizarPerfilAPartirDoJson(usuario);
      return;
    }

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
    required String cpf,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'cpf': cpf,
        'email': email,
        'telefone': telefone,
        'senha': senha,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final prefs = await SharedPreferences.getInstance();
      try {
        final data = jsonDecode(response.body);

        if (data['usuario'] != null) {
          final usuario = data['usuario'];
          await prefs.setString('usuario', jsonEncode(usuario));

          if (usuario['id'] != null) {
            await prefs.setString('user_id', usuario['id'].toString());
          }

          AppState.atualizarPerfilAPartirDoJson(usuario);
        }

        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
        }
      } catch (_) {}
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

  /// Usuário logado (JSON bruto)
  static Future<Map<String, dynamic>?> getUsuarioLogado() async {
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

  static Future<String?> getUserId() async {
    // se tiver gateway (pra testes/mock), usa ele
    if (AppState.authGateway != null) {
      return await AppState.authGateway!.getUserId();
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Esqueci a senha → fluxo por e-mail
  static Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao solicitar redefinição de senha');
    }
  }

  /// Reset de senha via CPF (fluxo local do app)
  static Future<void> resetPasswordByCpf({
    required String email,
    required String cpf,
    required String novaSenha,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/reset-password/by-cpf'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'cpf': cpf, 'novaSenha': novaSenha}),
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
    // se tiver gateway, delega
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

    final response = await http.put(
      Uri.parse('$baseUrl/users/profile/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
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

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Erro ao atualizar perfil');
    }
  }

  /// Salva ID manualmente (caso precise)
  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
  }

  /// Logout
  static Future<void> logout() async {
    if (AppState.authGateway != null) {
      return await AppState.authGateway!.logout();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
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

    if (response.statusCode != 200) {
      try {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Erro ao excluir conta');
      } catch (_) {
        throw Exception('Erro ao excluir conta no servidor.');
      }
    }
  }
}
