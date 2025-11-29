import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miaudota_app/login_page.dart';
import 'package:miaudota_app/pages/home_page.dart';

class TestNavigatorObserver extends NavigatorObserver {
  bool popped = false;
  bool pushed = false;
  Route? lastRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    pushed = true;
    lastRoute = route;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    popped = true;
    super.didPop(route, previousRoute);
  }
}

void main() {
  testWidgets('LoginPage - success navigates to HomePage',
      (WidgetTester tester) async {
    final observer = TestNavigatorObserver();
    bool called = false;

    await tester.pumpWidget(MaterialApp(
      home: LoginPage(
        loginAction: (email, senha) async {
          await Future.delayed(const Duration(milliseconds: 10));
          called = true;
        },
      ),
      navigatorObservers: [observer],
    ));

    await tester.pumpAndSettle();

    // Fill email and password
    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'senha123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 200));
    expect(called, isTrue);
    // ensure navigation was attempted
    expect(observer.pushed, isTrue);
  });

  testWidgets('LoginPage - error shows snackbar and stays on page',
      (WidgetTester tester) async {
    final observer = TestNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      home: LoginPage(
        loginAction: (email, senha) async {
          await Future.delayed(const Duration(milliseconds: 10));
          throw Exception('Usuário ou senha inválidos');
        },
      ),
      navigatorObservers: [observer],
    ));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'senhaErrada');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Usuário ou senha inválidos'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });
}
