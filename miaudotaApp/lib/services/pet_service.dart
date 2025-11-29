import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PetService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  // LISTAR PETS (igual está)
  static Future<List<dynamic>> getPets() async {
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
      if (decoded is List) return decoded;
      throw Exception('Resposta inesperada da API');
    }

    try {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Erro ao carregar pets');
    } catch (_) {
      throw Exception('Erro ao carregar pets');
    }
  }

  // 🔥 CRIAR PET COM UPLOAD DE FOTO
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
    int? usuarioId,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$baseUrl/pets');

    final request = http.MultipartRequest('POST', uri);

    // campos normais
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

    // arquivo (se tiver)
    if (fotoFile != null) {
      final multipartFile = await http.MultipartFile.fromPath(
        'foto', // 👈 TEM QUE SER O MESMO NOME DO upload.single('foto')
        fotoFile.path,
      );
      request.files.add(multipartFile);
    }

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    try {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Erro ao cadastrar pet');
    } catch (_) {
      throw Exception('Erro ao cadastrar pet');
    }
  }
}
