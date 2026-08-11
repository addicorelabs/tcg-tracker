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

  group('how many rounds a tournament can have', () {
    test('a top 8 adds three rounds to the swiss', () {
      expect(
        EventOptions.maxRounds(
          roundsPlanned: 10,
          hasTopCut: true,
          topCutSize: 8,
        ),
        13,
      );
    });

    test('each doubling of the cut adds one more round', () {
      int rounds(int cut) => EventOptions.maxRounds(
        roundsPlanned: 0,
        hasTopCut: true,
        topCutSize: cut,
      );

      expect(
        [rounds(4), rounds(8), rounds(16), rounds(32), rounds(64)],
        [2, 3, 4, 5, 6],
      );
    });

    test('without a cut the swiss rounds are all there is', () {
      expect(
        EventOptions.maxRounds(roundsPlanned: 9, hasTopCut: false),
        9,
        reason: 'the size is ignored when the flag says there was no cut',
      );
      expect(
        EventOptions.maxRounds(
          roundsPlanned: 9,
          hasTopCut: false,
          topCutSize: 8,
        ),
        9,
      );
    });

    test('a cut size that is not a power of two rounds up', () {
      expect(
        EventOptions.maxRounds(
          roundsPlanned: 5,
          hasTopCut: true,
          topCutSize: 12,
        ),
        9,
        reason:
            'twelve players need four rounds to resolve, the same as sixteen: '
            'answering short would put a real round out of reach',
      );
    });

    test('a cut with nothing to play out adds nothing', () {
      expect(
        EventOptions.maxRounds(
          roundsPlanned: 6,
          hasTopCut: true,
          topCutSize: 1,
        ),
        6,
      );
    });
  });
}
