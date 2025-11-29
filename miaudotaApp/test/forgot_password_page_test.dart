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
  testWidgets('ForgotPasswordPage - local reset success flow',
      (WidgetTester tester) async {
    final observer = TestNavigatorObserver();
    bool called = false;

    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordPage(
        resetPasswordByCpfAction: ({required email, required cpf, required novaSenha}) async {
          await Future.delayed(const Duration(milliseconds: 10));
          called = true;
        },
      ),
      navigatorObservers: [observer],
    ));

    await tester.pumpAndSettle();

    // fill fields
    final allTextFields = find.byType(TextFormField);
    expect(allTextFields, findsWidgets);

    await tester.enterText(allTextFields.at(0), 'user@example.com');
    await tester.enterText(allTextFields.at(1), '12345678901');
    await tester.enterText(allTextFields.at(2), 'novaSenha123');
    await tester.enterText(allTextFields.at(3), 'novaSenha123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Redefinir senha'));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(called, isTrue);
    expect(observer.didPopCalled, isTrue);
  });

  testWidgets('ForgotPasswordPage - local reset shows error', (WidgetTester tester) async {
    final observer = TestNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordPage(
        resetPasswordByCpfAction: ({required email, required cpf, required novaSenha}) async {
          await Future.delayed(const Duration(milliseconds: 10));
          throw Exception('CPF não confere');
        },
      ),
      navigatorObservers: [observer],
    ));

    await tester.pumpAndSettle();

    final allTextFields = find.byType(TextFormField);
    await tester.enterText(allTextFields.at(0), 'user@example.com');
    await tester.enterText(allTextFields.at(1), '12345678901');
    await tester.enterText(allTextFields.at(2), 'novaSenha123');
    await tester.enterText(allTextFields.at(3), 'novaSenha123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Redefinir senha'));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('CPF não confere'), findsOneWidget);
    expect(observer.didPopCalled, isFalse);
  });

  // tests for the active (temporary disabled) UI: pressing the button shows an 'disabled' snackbar.

  // End of tests

  testWidgets('ForgotPasswordPage - email link flow success', (WidgetTester tester) async {
    bool called = false;
    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordPage(
        forgotPasswordAction: (email) async {
          await Future.delayed(const Duration(milliseconds: 10));
          called = true;
        },
      ),
    ));

    await tester.pumpAndSettle();

    // turn on email link option
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final allTextFields = find.byType(TextFormField);
    await tester.enterText(allTextFields.at(0), 'user@example.com');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Enviar link'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(called, isTrue);
  });

  testWidgets('ForgotPasswordPage - email link shows error', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordPage(
        forgotPasswordAction: (email) async {
          await Future.delayed(const Duration(milliseconds: 10));
          throw Exception('Erro ao enviar e-mail');
        },
      ),
    ));

    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final allTextFields = find.byType(TextFormField);
    await tester.enterText(allTextFields.at(0), 'user@example.com');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Enviar link'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Erro ao enviar e-mail'), findsOneWidget);
  });
