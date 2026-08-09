import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/features/life/domain/life_game.dart';
import 'package:tcg_tracker/features/life/providers/life_counter_provider.dart';

import '../helpers/app_harness.dart';

void main() {
  group('the counter itself', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // A fixed seed, so a die that must land somewhere lands predictably.
          lifeCounterProvider.overrideWith(
            () => LifeCounterNotifier(random: Random(7)),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    LifeCounterNotifier notifier() =>
        container.read(lifeCounterProvider.notifier);
    LifeGame game() => container.read(lifeCounterProvider)!;

    test('a game starts both players on the same total', () {
      notifier().start(gameId: Seed.yugiohId);

      expect(game().me.life, 8000);
      expect(game().opponent.life, 8000);
      expect(game().startingLife, 8000);
    });

    test('Magic starts at 20 without being told', () {
      notifier().start(gameId: Seed.magicId);

      expect(game().me.life, 20);
    });

    test('a life change is applied and written down', () {
      notifier().start(gameId: Seed.yugiohId);
      notifier().adjustLife(Seat.opponent, -1800);

      expect(game().opponent.life, 6200);
      expect(game().me.life, 8000, reason: 'the other seat is untouched');

      final entry = game().log.single as LifeChanged;
      expect(entry.delta, -1800);
      expect(entry.total, 6200);
    });

    test('undo takes back the last change to a total', () {
      notifier().start(gameId: Seed.magicId);
      notifier().adjustLife(Seat.me, -3);
      notifier().adjustLife(Seat.me, -5);
      notifier().undo();

      expect(game().me.life, 17);
      expect(game().log, hasLength(1));
    });

    test('undo leaves dice and coins alone', () {
      notifier().start(gameId: Seed.magicId);
      notifier().adjustLife(Seat.me, -3);
      notifier().rollDice(20);
      notifier().undo();

      expect(game().me.life, 20, reason: 'the life change was the one undone');
      expect(
        game().log.single,
        isA<DiceRolled>(),
        reason: 'a roll is a record of what happened, not a mistake to revert',
      );
    });

    test('counters never go below zero', () {
      notifier().start(gameId: Seed.magicId);
      notifier().adjustCounter(Seat.me, CounterKind.poison, 1);
      notifier().adjustCounter(Seat.me, CounterKind.poison, -1);
      notifier().adjustCounter(Seat.me, CounterKind.poison, -1);

      expect(game().me.counter(CounterKind.poison), 0);
      expect(
        game().log,
        hasLength(2),
        reason: 'the change that would have gone negative was not recorded',
      );
    });

    test('a die lands within its own faces', () {
      notifier().start(gameId: Seed.magicId);

      for (var i = 0; i < 50; i++) {
        expect(notifier().rollDice(20), inInclusiveRange(1, 20));
        expect(notifier().rollDice(6), inInclusiveRange(1, 6));
      }
    });

    test('restarting keeps the setup and drops everything else', () {
      notifier().start(gameId: Seed.yugiohId, startingLife: 4000);
      notifier().adjustLife(Seat.me, -1000);
      notifier().flipCoin();
      notifier().restart();

      expect(game().me.life, 4000);
      expect(game().startingLife, 4000);
      expect(game().log, isEmpty);
    });

    test('life can go negative, because a game is not over until it is', () {
      notifier().start(gameId: Seed.magicId);
      notifier().adjustLife(Seat.opponent, -25);

      expect(game().opponent.life, -5);
      expect(game().defeated, Seat.opponent);
    });
  });

  group('on screen', () {
    late AppHarness harness;

    setUp(() async {
      harness = await AppHarness.create();
    });

    /// Tall enough that the quick action and both seats fit without scrolling.
    const tallPhone = Size(400, 1600);

    Future<void> openCounter(WidgetTester tester) async {
      setSurfaceSize(tester, tallPhone);
      await tester.pumpWidget(harness.app);
      await tester.pumpAndSettle();

      await tester.tap(find.text('NEW MATCH'));
      await tester.pumpAndSettle();
    }

    testWidgets('the setup offers the starting life of the chosen game', (
      tester,
    ) async {
      await openCounter(tester);

      expect(find.widgetWithText(ChoiceChip, '8000'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, '20'), findsNothing);

      await tester.tap(find.text('Magic: The Gathering'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ChoiceChip, '20'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, '40'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('a tap takes the step off the right player', (tester) async {
      await openCounter(tester);
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // Two seats, so two minus buttons: the last one is the near side.
      await tester.tap(find.byIcon(Icons.remove).last);
      await tester.pumpAndSettle();

      expect(find.text('7500'), findsOneWidget);
      expect(find.text('8000'), findsOneWidget, reason: 'the opponent is not');

      await unmount(tester);
    });

    testWidgets('changing the step changes what a tap is worth', (
      tester,
    ) async {
      await openCounter(tester);
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, '100'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.remove).last);
      await tester.pumpAndSettle();

      expect(find.text('7900'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('the counter survives a walk to another section', (
      tester,
    ) async {
      await openCounter(tester);
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.remove).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.emoji_events_outlined).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();

      expect(
        find.text('7500'),
        findsOneWidget,
        reason: 'a game in progress must not reset because a tab was tapped',
      );

      await unmount(tester);
    });
  });
}
