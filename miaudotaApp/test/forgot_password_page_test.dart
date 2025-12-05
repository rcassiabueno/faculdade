import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ajuste o path conforme onde está o arquivo:
import 'package:miaudota_app/forgot_password_page.dart';

class TestNavigatorObserver extends NavigatorObserver {
  bool didPopCalled = false;

  @override
  void didPop(Route route, Route? previousRoute) {
    didPopCalled = true;
    super.didPop(route, previousRoute);
  }
}

void main() {
  testWidgets('ForgotPasswordPage - reset success flow', (
    WidgetTester tester,
  ) async {
    final observer = TestNavigatorObserver();
    bool called = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ForgotPasswordPage(
          resetPasswordAction:
              ({
                required String email,
                String? cpf,
                String? cnpj,
                required String novaSenha,
              }) async {
                // aqui só marcamos que foi chamado
                called = true;
              },
        ),
        navigatorObservers: [observer],
      ),
    );

    await tester.pumpAndSettle();

    // 4 TextFormField: e-mail, doc, nova senha, confirma
    final allTextFields = find.byType(TextFormField);
    expect(allTextFields, findsNWidgets(4));

    await tester.enterText(allTextFields.at(0), 'user@example.com');
    await tester.enterText(allTextFields.at(1), '12345678901');
    await tester.enterText(allTextFields.at(2), 'novaSenha123');
    await tester.enterText(allTextFields.at(3), 'novaSenha123');

    await tester.pumpAndSettle();

    final buttonRedefinir = find.widgetWithText(
      ElevatedButton,
      'Redefinir senha',
    );
    await tester.ensureVisible(buttonRedefinir);
    await tester.tap(buttonRedefinir);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // garante que a action foi chamada
    expect(called, isTrue);

    // se quiser, dá pra checar se houve pop no sucesso:
    // expect(observer.didPopCalled, isTrue);
  });

  testWidgets('ForgotPasswordPage - reset shows error', (
    WidgetTester tester,
  ) async {
    final observer = TestNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        home: ForgotPasswordPage(
          resetPasswordAction:
              ({
                required String email,
                String? cpf,
                String? cnpj,
                required String novaSenha,
              }) async {
                await Future.delayed(const Duration(milliseconds: 10));
                throw Exception('CPF não confere');
              },
        ),
        navigatorObservers: [observer],
      ),
    );

    await tester.pumpAndSettle();

    final allTextFields = find.byType(TextFormField);
    expect(allTextFields, findsNWidgets(4));

    await tester.enterText(allTextFields.at(0), 'user@example.com');
    await tester.enterText(allTextFields.at(1), '12345678901');
    await tester.enterText(allTextFields.at(2), 'novaSenha123');
    await tester.enterText(allTextFields.at(3), 'novaSenha123');
    await tester.pumpAndSettle();

    final buttonRedefinir = find.widgetWithText(
      ElevatedButton,
      'Redefinir senha',
    );
    await tester.ensureVisible(buttonRedefinir);
    await tester.tap(buttonRedefinir);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // deve mostrar SnackBar com a mensagem tratada
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('CPF não confere'), findsOneWidget);

    // em caso de erro, não volta pra tela anterior
    expect(observer.didPopCalled, isFalse);
  });

  // ========================
  // TESTES DO FLUXO POR E-MAIL (antigo)
  // Mantidos como referência, mas desativados
  // ========================

  testWidgets('ForgotPasswordPage - email link flow success (deprecated UI)', (
    WidgetTester tester,
  ) async {
    expect(true, isTrue);
  }, skip: true);

  testWidgets('ForgotPasswordPage - email link shows error (deprecated UI)', (
    WidgetTester tester,
  ) async {
    expect(true, isTrue);
  }, skip: true);
}
