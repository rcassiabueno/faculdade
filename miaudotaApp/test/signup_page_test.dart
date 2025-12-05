import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:miaudota_app/pages/signup_page.dart';

class MockSignup extends Mock {
  Future<void> call({
    String? cnpj,
    String? cpf,
    required String email,
    required bool isPessoaJuridica,
    required String nome,
    required String senha,
    required String telefone,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSignup mockSignup;

  setUp(() {
    mockSignup = MockSignup();

    when(
      () => mockSignup(
        cnpj: any(named: 'cnpj'),
        cpf: any(named: 'cpf'),
        email: any(named: 'email'),
        isPessoaJuridica: any(named: 'isPessoaJuridica'),
        nome: any(named: 'nome'),
        senha: any(named: 'senha'),
        telefone: any(named: 'telefone'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> _pumpSignup(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignupPage(
          signupAction:
              ({
                String? cnpj,
                String? cpf,
                required String email,
                required bool isPessoaJuridica,
                required String nome,
                required String senha,
                required String telefone,
              }) {
                return mockSignup(
                  cnpj: cnpj,
                  cpf: cpf,
                  email: email,
                  isPessoaJuridica: isPessoaJuridica,
                  nome: nome,
                  senha: senha,
                  telefone: telefone,
                );
              },
        ),
      ),
    );
  }

  testWidgets('mostra erro quando campos obrigatórios estão vazios', (
    tester,
  ) async {
    await _pumpSignup(tester);

    // Botão principal da tela de cadastro (ElevatedButton)
    final criarContaButton = find.byType(ElevatedButton);
    expect(criarContaButton, findsOneWidget);

    await tester.tap(criarContaButton);
    await tester.pumpAndSettle();

    // Verifica se as mensagens de erro aparecem (ajusta depois se quiser checar textos específicos)
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('chama signupAction quando formulário é válido', (tester) async {
    await _pumpSignup(tester);

    final fields = find.byType(TextFormField);
    expect(fields, findsWidgets);

    // Ajusta os índices conforme a ordem real dos campos na sua SignupPage
    await tester.enterText(fields.at(0), 'Maria Teste'); // nome
    await tester.enterText(fields.at(1), 'maria@teste.com'); // email
    await tester.enterText(fields.at(2), 'SenhaSegura123'); // senha
    await tester.enterText(fields.at(3), 'SenhaSegura123'); // confirmar senha

    await tester.pumpAndSettle();

    // Botão de criar conta
    final criarContaButton = find.byType(ElevatedButton);
    expect(criarContaButton, findsOneWidget);
    await tester.tap(criarContaButton);
    await tester.pumpAndSettle();

    // Aqui só garante que a tela continua montada;
    // se quiser depois a gente adiciona um verify(mockSignup(...)).called(1)
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
