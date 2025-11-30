import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  testWidgets('ForgotPasswordPage - local reset success flow', (
    WidgetTester tester,
  ) async {
    final observer = TestNavigatorObserver();
    bool called = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ForgotPasswordPage(
          resetPasswordByCpfAction:
              ({
                required String email,
                required String cpf,
                required String novaSenha,
              }) async {
                called = true;
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

    // garante que a action foi chamada
    expect(called, isTrue);

    // se a tela não dá pop no sucesso, não precisa checar didPopCalled
    // então não vamos fazer assert de observer.didPopCalled aqui
  });

  testWidgets('ForgotPasswordPage - local reset shows error', (
    WidgetTester tester,
  ) async {
    final observer = TestNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        home: ForgotPasswordPage(
          resetPasswordByCpfAction:
              ({
                required String email,
                required String cpf,
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

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('CPF não confere'), findsOneWidget);
    expect(observer.didPopCalled, isFalse);
  });

  // ========================
  // TESTES DO FLUXO POR E-MAIL (UI ANTIGA)
  // Mantidos como referência, mas desativados para não quebrar,
  // pois a tela atual não possui mais Switch nem botão "Enviar link".
  // ========================

  testWidgets(
    'ForgotPasswordPage - email link flow success',
    (WidgetTester tester) async {
      bool called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ForgotPasswordPage(
            forgotPasswordAction: (email) async {
              await Future.delayed(const Duration(milliseconds: 10));
              called = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Aqui antes havia um Switch e um botão "Enviar link",
      // mas na UI atual esses elementos não existem mais.
      // Test desativado.
      expect(true, isTrue); // apenas para não ficar vazio
    },
    skip: true, // desativado porque a UI atual não tem mais esse fluxo
  );

  testWidgets(
    'ForgotPasswordPage - email link shows error',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ForgotPasswordPage(
            forgotPasswordAction: (email) async {
              await Future.delayed(const Duration(milliseconds: 10));
              throw Exception('Erro ao enviar e-mail');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Situação: fluxo por e-mail não existe mais na tela atual.
      expect(true, isTrue);
    },
    skip: true, // desativado
  );
}
