import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// PetParaAdocao está definido em main.dart
import 'package:miaudota_app/main.dart';
import 'package:miaudota_app/pets/pets_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mostra indicador de carregamento enquanto busca pets', (
    tester,
  ) async {
    // agora o completer é de List<PetParaAdocao>
    final completer = Completer<List<PetParaAdocao>>();

    await tester.pumpWidget(
      MaterialApp(home: PetsPage(loadPets: () => completer.future)),
    );

    // estado inicial: Future pendente → loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // completa a future
    completer.complete(<PetParaAdocao>[]);
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
      MaterialApp(home: PetsPage(loadPets: () async => <PetParaAdocao>[])),
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
          loadPets: () async => <PetParaAdocao>[
            PetParaAdocao(
              id: 1,
              nome: 'Tom',
              descricao: 'Gato carinhoso',
              especie: 'Gato',
              raca: 'SRD',
              idade: '2 anos',
              bairro: 'Centro',
              cidade: 'Itajaí',
              estado: 'SC',
              // usa uma URL qualquer para evitar AssetImage("")
              imagemPath: 'https://example.com/tom.png',
              telefoneTutor: '47999999999',
            ),
            PetParaAdocao(
              id: 2,
              nome: 'Luna',
              descricao: 'Cachorra alegre',
              especie: 'Cachorro',
              raca: 'SRD',
              idade: '3 anos',
              bairro: 'Centro',
              cidade: 'Itajaí',
              estado: 'SC',
              imagemPath: 'https://example.com/luna.png',
              telefoneTutor: '47999999999',
            ),
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
