import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miaudota_app/main.dart';

class AuthService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  static Future<void> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "senha": senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final usuario = data['usuario'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario', jsonEncode(data['usuario']));

      if (data['token'] != null) {
        await prefs.setString('token', data['token']);
      }

      AppState.atualizarPerfilAPartirDoJson(usuario);

      await prefs.setInt('user_id', usuario['id']);
    } else {
      String message;
      try {
        final body = jsonDecode(response.body);
        message = body['error'] ?? body['message'] ?? 'Erro ao fazer login';
      } catch (_) {
        message = 'Erro ${response.statusCode}: ${response.reasonPhrase}';
      }
      throw Exception(message);
    }
  }

  // ✅ CADASTRO USANDO /users/register
  static Future<void> signup({
    required String nome,
    required String cpf,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nome": nome,
        "cpf": cpf,
        "email": email,
        "telefone": telefone,
        "senha": senha,
      }),
    );

    print('SIGNUP status: ${response.statusCode}');
    print('SIGNUP body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        // 👇 se o backend devolve "usuario" igual no register:
        if (data['usuario'] != null) {
          final usuario = data['usuario'];

          // salva usuário bruto
          await prefs.setString('usuario', jsonEncode(usuario));

          // salva ID para usar no updateProfile, pets etc.
          if (usuario['id'] != null) {
            await prefs.setInt('user_id', usuario['id']);
          }

          // atualiza perfil em memória (AppState)
          AppState.atualizarPerfilAPartirDoJson(usuario);
        }

        // se um dia você devolver token no register, já tá pronto:
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
        }
      } catch (e) {
        // se não vier JSON estruturado, só loga e segue
        print('Erro ao processar resposta do signup: $e');
      }
      return;
    }

    // erro
    String message;
    try {
      final body = jsonDecode(response.body);
      message = body['error'] ?? body['message'] ?? 'Erro ao criar conta';
    } catch (_) {
      message = 'Erro ${response.statusCode}: ${response.reasonPhrase}';
    }
    throw Exception(message);
  }

  static Future<Map<String, dynamic>?> getUsuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('usuario');
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // retorna null se não tiver token
  }

  static Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/forgot-password'), // 👈 tem que estar assim
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao solicitar redefinição de senha');
    }
  }

  static Future<void> resetPasswordByCpf({
    required String email,
    required String cpf,
    required String novaSenha,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/reset-password/by-cpf'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "cpf": cpf, "novaSenha": novaSenha}),
    );

    if (response.statusCode != 200) {
      try {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? body['message'] ?? 'Erro ao redefinir senha');
      } catch (_) {
        throw Exception('Erro ${response.statusCode}: ${response.reasonPhrase}');
      }
    }
  }

  static Future<void> updateProfile({
    required int userId,
    required String nome,
    required String cpf,
    required String telefone,
    required String cidade,
    required String estado,
    required String bairro,
    String? cnpj,
    bool isPessoaJuridica = false,
  }) async {
    final url = Uri.parse('$baseUrl/users/profile/$userId');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        // se depois você tiver token, coloca Authorization aqui
      },
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

  // dica: guarde também o id do usuário ao fazer login
  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
    await prefs.remove('token');
  }

  static Future<void> deleteAccount(int userId) async {
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
