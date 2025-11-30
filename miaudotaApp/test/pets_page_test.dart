import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miaudota_app/pets/pets_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mostra indicador de carregamento enquanto busca pets', (
    tester,
  ) async {
    final completer = Completer<List<dynamic>>();

    await tester.pumpWidget(
      MaterialApp(home: PetsPage(loadPets: () => completer.future)),
    );

    // estado inicial: Future pendente → loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // completa a future
    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('mostra mensagem de erro quando Future retorna erro', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PetsPage(
          loadPets: () async {
            throw Exception('Falha de rede');
          },
        ),
      ),
    );

    // Primeiro frame: loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(
      find.text('Erro ao carregar pets. Tente novamente mais tarde.'),
      findsOneWidget,
    );
  });

  testWidgets('mostra mensagem de lista vazia quando não há pets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: PetsPage(loadPets: () async => [])),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Nenhum pet disponível para adoção no momento.'),
      findsOneWidget,
    );
  });

  testWidgets('mostra lista quando há pets retornados', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PetsPage(
          loadPets: () async => [
            {'nome': 'Tom', 'descricao': 'Gato carinhoso', 'foto': ''},
            {'nome': 'Luna', 'descricao': 'Cachorra alegre', 'foto': ''},
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}
