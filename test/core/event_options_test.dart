import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/core/tournaments/event_options.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/models/enums.dart';

void main() {
  group('event types', () {
    test('Yu-Gi-Oh! runs OTS and continental events, never a PTQ', () {
      final types = EventOptions.typesFor(Seed.yugiohId);

      expect(
        types,
        containsAll([
          EventType.local,
          EventType.ots,
          EventType.regional,
          EventType.national,
          EventType.continental,
          EventType.worlds,
          EventType.online,
        ]),
      );
      expect(types, isNot(contains(EventType.ptq)));
      expect(types, isNot(contains(EventType.storeChampionship)));
    });

    test('Magic runs store championships, showdowns and PTQs', () {
      final types = EventOptions.typesFor(Seed.magicId);

      expect(
        types,
        containsAll([
          EventType.local,
          EventType.storeChampionship,
          EventType.showdown,
          EventType.regional,
          EventType.ptq,
          EventType.worlds,
          EventType.online,
        ]),
      );
      expect(types, isNot(contains(EventType.ots)));
      expect(types, isNot(contains(EventType.continental)));
    });

    test('an editor keeps showing a type the game no longer offers', () {
      // A Magic tournament recorded as national before the lists existed must
      // still open on its own value instead of silently changing type.
      expect(
        EventOptions.typesForEditing(Seed.magicId, EventType.national),
        contains(EventType.national),
      );
      expect(
        EventOptions.typesForEditing(Seed.magicId, EventType.ptq),
        EventOptions.typesFor(Seed.magicId),
        reason: 'a type already on offer must not be added twice',
      );
    });
  });

  group('top cut sizes', () {
    test('Yu-Gi-Oh! cuts as deep as a top 64', () {
      expect(EventOptions.topCutSizesFor(Seed.yugiohId), [4, 8, 16, 32, 64]);
    });

    test('Magic stops at a top 16', () {
      expect(EventOptions.topCutSizesFor(Seed.magicId), [4, 8, 16]);
    });

    test('a stored size outside the list stays visible, in order', () {
      expect(EventOptions.topCutSizesForEditing(Seed.magicId, 32), [
        4,
        8,
        16,
        32,
      ]);
    });
  });
}
