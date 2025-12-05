import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miaudota_app/main.dart';
// Ajuste o caminho conforme sua estrutura real:
import 'package:miaudota_app/pets/pet_form_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Perfil incompleto por padrão
    AppState.userProfile = UserProfile(
      nome: '',
      cpf: '',
      cnpj: '',
      isPessoaJuridica: false,
      email: '',
      telefone: '',
      estado: '',
      cidade: '',
      bairro: '',
    );

    AppState.petsParaAdocao.clear();
    AppState.petsAdotados.clear();
    AppState.solicitacoesPendentes.clear();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PetFormPage())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'mostra snackbar pedindo para completar cadastro se perfil estiver incompleto',
    (tester) async {
      await pumpPage(tester);

      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar');
      await tester.ensureVisible(salvarButton);
      await tester.tap(salvarButton);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Complete seu cadastro antes de salvar um pet para adoção.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'com perfil completo, mostra snackbar se tentar salvar sem foto do pet',
    (tester) async {
      // Perfil completo
      AppState.userProfile = UserProfile(
        nome: 'Tutor',
        cpf: '11122233344',
        cnpj: '',
        isPessoaJuridica: false,
        email: 'tutor@teste.com',
        telefone: '47999999999',
        estado: 'SC',
        cidade: 'Itajaí',
        bairro: 'Centro',
      );

      await pumpPage(tester);

      // Preenche campos obrigatórios
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do pet* (ex: Tom)'),
        'Tom',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Espécie* (ex: Gato, Cachorro)'),
        'Gato',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Raça* (ex: SRD, Siamês)'),
        'SRD',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Idade* (ex: 2 anos, 4 meses)'),
        '2 anos',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Bairro do pet*'),
        'Centro',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cidade do pet*'),
        'Itajaí',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Descrição do pet* (temperamento, cuidados, etc.)',
        ),
        'Manso e carinhoso.',
      );

      // Seleciona estado
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SC').last);
      await tester.pumpAndSettle();

      // NÃO adiciona foto

      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar');
      await tester.ensureVisible(salvarButton);
      await tester.tap(salvarButton);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Adicione uma foto do pet.'), findsOneWidget);
    },
  );
}
