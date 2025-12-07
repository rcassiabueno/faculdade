import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PetService {
  // Reaproveita a baseUrl do AuthService:
  static String get baseUrl => AuthService.baseUrl;

  // ============================================================
  // LISTAR PETS
  // ============================================================
  static Future<List<Map<String, dynamic>>> getPets() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/pets'),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }

      throw Exception('Resposta inesperada da API: não é uma lista.');
    }

    try {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Erro ao carregar pets');
    } catch (_) {
      throw Exception('Erro ao carregar pets');
    }
  }

  // ============================================================
  // CRIAR PET (POST)
  // ============================================================
  // CRIAR PET COM UPLOAD DE FOTO
  static Future<Map<String, dynamic>> createPet({
    required String nome,
    required String especie,
    required String raca,
    required String idade,
    required String descricao,
    required String cidade,
    required String estado,
    required String bairro,
    required String telefoneTutor,
    File? fotoFile,
    String? fotoUrl,
    int? usuarioId,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$baseUrl/pets');

    final request = http.MultipartRequest('POST', uri);

    request.fields['nome'] = nome;
    request.fields['especie'] = especie;
    request.fields['raca'] = raca;
    request.fields['idade'] = idade;
    request.fields['descricao'] = descricao;
    request.fields['cidade'] = cidade;
    request.fields['estado'] = estado;
    request.fields['bairro'] = bairro;
    request.fields['telefoneTutor'] = telefoneTutor;
    if (usuarioId != null) {
      request.fields['usuario_id'] = usuarioId.toString();
    }
    if (fotoUrl != null && fotoUrl.trim().isNotEmpty) {
      request.fields['foto_url'] = fotoUrl.trim();
    }

    if (fotoFile != null) {
      final multipartFile = await http.MultipartFile.fromPath(
        'foto', // mesmo nome do upload.single('foto')
        fotoFile.path,
      );
      request.files.add(multipartFile);
    }

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    // 💡 DEBUG FORTE AQUI
    // (olha isso no console do Flutter)
    print('================= PET CREATE DEBUG =================');
    print('URL: $uri');
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');
    print('====================================================');

    // Aceita sucesso com 200 ou 201
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    try {
      final body = jsonDecode(response.body);
      throw Exception(
        body['error'] ?? body['message'] ?? 'Erro ao cadastrar pet',
      );
    } catch (_) {
      throw Exception('Erro ao cadastrar pet (status ${response.statusCode})');
    }
  }

  // ============================================================
  // ATUALIZAR PET (PUT /pets/:id)
  // ============================================================
  static Future<Map<String, dynamic>> updatePet({
    required int id,
    required String nome,
    required String especie,
    required String raca,
    required String idade,
    required String descricao,
    required String cidade,
    required String estado,
    required String bairro,
    required String telefoneTutor,
    File? fotoFile,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$baseUrl/pets/$id');

    final request = http.MultipartRequest('PUT', uri);

    request.fields.addAll({
      'nome': nome,
      'especie': especie,
      'raca': raca,
      'idade': idade,
      'descricao': descricao,
      'cidade': cidade,
      'estado': estado,
      'bairro': bairro,
      'telefoneTutor': telefoneTutor,
    });

    // Foto opcional — servidor deve manter a antiga se não enviar nova
    if (fotoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', fotoFile.path),
      );
    }

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    dev.log(
      'UPDATE PET → Status: ${response.statusCode}\nBody: ${response.body}',
      name: 'PetService',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    try {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Erro ao atualizar pet');
    } catch (_) {
      throw Exception('Erro ao atualizar pet');
    }
  }
}
