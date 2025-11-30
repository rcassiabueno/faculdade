abstract class AuthGateway {
  Future<String?> getUserId();
  Future<void> updateProfile({
    required String userId,
    required String nome,
    required String cpf,
    required String telefone,
    required String cidade,
    required String estado,
    required String bairro,
    String? cnpj,
    bool isPessoaJuridica = false,
  });
  Future<void> deleteAccount(String userId);
  Future<void> logout();
}
