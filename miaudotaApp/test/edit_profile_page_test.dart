import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:miaudota_app/pages/profile/edit_profile_page.dart';
import 'package:miaudota_app/main.dart';
import 'package:miaudota_app/gateways/auth_gateway.dart';

class MockAuthGateway extends Mock implements AuthGateway {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthGateway auth;

  setUp(() {
    auth = MockAuthGateway();

    SharedPreferences.setMockInitialValues({});

    AppState.userProfile = UserProfile(
      nome: 'Maria Silva',
      cpf: '11122233344',
      cnpj: '',
      isPessoaJuridica: false,
      email: 'f@x.com',
      telefone: '11999999999',
      estado: 'SP',
      cidade: 'São Paulo',
      bairro: 'Centro',
    );

    AppState.authGateway = auth;

    when(() => auth.getUserId()).thenAnswer((_) async => 'u-1');

    when(
      () => auth.updateProfile(
        userId: any(named: 'userId'),
        nome: any(named: 'nome'),
        cpf: any(named: 'cpf'),
        telefone: any(named: 'telefone'),
        cidade: any(named: 'cidade'),
        estado: any(named: 'estado'),
        bairro: any(named: 'bairro'),
        cnpj: any(named: 'cnpj'),
        isPessoaJuridica: any(named: 'isPessoaJuridica'),
      ),
    ).thenAnswer((_) async {});

    when(() => auth.deleteAccount(any())).thenAnswer((_) async {});
    when(() => auth.logout()).thenAnswer((_) async {});
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: EditProfilePage()));
    await tester.pumpAndSettle();
  }

  testWidgets('preenche campos com dados do perfil atual', (tester) async {
    await pumpPage(tester);

    final nomeField = find.byKey(const Key('nomeField'));
    final cpfField = find.byKey(const Key('cpfField'));
    final emailField = find.byKey(const Key('emailField'));
    final estadoField = find.byKey(const Key('estadoField'));

    expect(nomeField, findsOneWidget);
    expect(cpfField, findsOneWidget);
    expect(emailField, findsOneWidget);
    expect(estadoField, findsOneWidget);

    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.text('f@x.com'), findsOneWidget);
    expect(find.text('SP'), findsOneWidget);

    // Se quiser validar o valor bruto do CPF via controller:
    final cpfTextField = tester.widget<TextFormField>(cpfField);
    expect(cpfTextField.controller?.text, '11122233344');
  });

  testWidgets('mostra erro se tentar salvar com CPF vazio', (tester) async {
    await pumpPage(tester);

    final cpfField = find.byKey(const Key('cpfField'));
    final salvarButton = find.byKey(const Key('salvarButton'));

    await tester.ensureVisible(cpfField);
    await tester.enterText(cpfField, '');

    await tester.ensureVisible(salvarButton);
    await tester.tap(salvarButton);
    await tester.pumpAndSettle();

    verifyNever(
      () => auth.updateProfile(
        userId: any(named: 'userId'),
        nome: any(named: 'nome'),
        cpf: any(named: 'cpf'),
        telefone: any(named: 'telefone'),
        cidade: any(named: 'cidade'),
        estado: any(named: 'estado'),
        bairro: any(named: 'bairro'),
        cnpj: any(named: 'cnpj'),
        isPessoaJuridica: any(named: 'isPessoaJuridica'),
      ),
    );
  });

  testWidgets('chama updateProfile quando o formulário é válido', (
    tester,
  ) async {
    await pumpPage(tester);

    final salvarButton = find.byKey(const Key('salvarButton'));
    await tester.ensureVisible(salvarButton);
    await tester.tap(salvarButton);
    await tester.pumpAndSettle();

    verify(
      () => auth.updateProfile(
        userId: any(named: 'userId'),
        nome: any(named: 'nome'),
        cpf: any(named: 'cpf'),
        telefone: any(named: 'telefone'),
        cidade: any(named: 'cidade'),
        estado: any(named: 'estado'),
        bairro: any(named: 'bairro'),
        cnpj: any(named: 'cnpj'),
        isPessoaJuridica: any(named: 'isPessoaJuridica'),
      ),
    ).called(1);
  });
}
