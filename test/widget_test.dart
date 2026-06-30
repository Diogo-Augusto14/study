import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meu_primeiro_app/main.dart';

Future<void> openHomeAfterSplash(WidgetTester tester) async {
  await tester.pumpWidget(const StudySwipeApp());
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
  // Pula o onboarding e faz o login de demonstração (admin / 123).
  await tester.tap(find.text('Pular'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, 'admin');
  await tester.enterText(find.byType(TextField).at(1), '123');
  await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
  await tester.pumpAndSettle();
}

void main() {
  group('ChatSafetyFilter', () {
    test('blocks offensive words, phrases and simple disguises', () {
      for (final message in [
        'Você é um idiota',
        'QUE OTÁRIO!',
        'Isso é uma merda',
        'Cala a boca',
        'Vai se ferrar',
        'i.d.i.o.t.a',
        'b-u-r-r-o',
        'foda-se',
      ]) {
        expect(ChatSafetyFilter.containsBlockedContent(message), isTrue);
      }
    });

    test('allows a respectful study message', () {
      expect(
        ChatSafetyFilter.containsBlockedContent(
          'Você quer revisar Física comigo amanhã?',
        ),
        isFalse,
      );
    });
  });

  testWidgets('shows the splash screen before opening the app', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudySwipeApp());
    await tester.pump();

    expect(find.text('Bem-vindo ao'), findsOneWidget);
    expect(find.text('StudyMatch'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('shows the study profile discovery screen', (
    WidgetTester tester,
  ) async {
    await openHomeAfterSplash(tester);

    expect(find.text('StudyMatch'), findsOneWidget);
    expect(find.text('Luiza'), findsOneWidget);
    expect(find.text('Engenharia Física'), findsOneWidget);
  });

  testWidgets('creates a match, blocks unsafe text and reports a profile', (
    WidgetTester tester,
  ) async {
    await openHomeAfterSplash(tester);

    await tester.tap(find.byIcon(Icons.favorite_rounded));
    await tester.pumpAndSettle();
    expect(find.text('É um match!'), findsOneWidget);

    await tester.tap(find.text('Ir para o chat'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Você é idiota');
    await tester.pump();
    expect(
      find.text('Mensagem bloqueada: remova a palavra inadequada para enviar.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byIcon(Icons.send_rounded),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(find.byType(TextField), 'Topa estudar esta semana?');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    expect(find.text('Luiza está digitando...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Termodinâmica'), findsOneWidget);

    await tester.tap(find.byTooltip('Denunciar usuário'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Usuário denunciado. Nossa equipe avaliará a conta nas próximas 24h.',
      ),
      findsOneWidget,
    );
  });
}
