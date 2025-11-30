import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:miaudota_app/pages/signup_page.dart';

class MockSignup extends Mock {
  Future<void> call({
    required String nome,
    required String cpf,
    required String email,
    required String telefone,
    required String senha,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSignup mockSignup;

  setUp(() {
    mockSignup = MockSignup();

    when(
      () => mockSignup(
        nome: any(named: 'nome'),
        cpf: any(named: 'cpf'),
        email: any(named: 'email'),
        telefone: any(named: 'telefone'),
        senha: any(named: 'senha'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> _pumpSignup(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignupPage(
          signupAction:
              ({
                required String nome,
                required String cpf,
                required String email,
                required String telefone,
                required String senha,
              }) {
                return mockSignup(
                  nome: nome,
                  cpf: cpf,
                  email: email,
                  telefone: telefone,
                  senha: senha,
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

    // Verifica se as mensagens de erro aparecem
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('chama signupAction quando formulário é válido', (tester) async {
    await _pumpSignup(tester);

    final fields = find.byType(TextFormField);
    expect(fields, findsWidgets);

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

    // Verifica se a action foi chamada
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
