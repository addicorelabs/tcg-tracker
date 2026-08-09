import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcg_tracker/data/backup/backup_service.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/database_provider.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';
import 'package:tcg_tracker/data/sync/sync_backend.dart';
import 'package:tcg_tracker/data/sync/sync_controller.dart';
import 'package:tcg_tracker/features/settings/providers/app_settings_provider.dart';

import '../helpers/fake_sync_backend.dart';
import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeSyncBackend backend;
  late ProviderContainer container;

  /// Short enough that the debounce can be waited out inside a test.
  const pushDelay = Duration(milliseconds: 20);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = createTestDatabase();
    backend = FakeSyncBackend();

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
        syncBackendProvider.overrideWithValue(backend),
        syncPushDelayProvider.overrideWithValue(pushDelay),
      ],
    );

    addTearDown(container.dispose);
    addTearDown(backend.dispose);
    addTearDown(db.close);

    // The controller opens the database and lets the seed settle before it
    // starts watching for changes, so a test that writes immediately would be
    // racing it.
    container.read(syncControllerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });

  SyncController controller() =>
      container.read(syncControllerProvider.notifier);

  Future<void> signIn() =>
      controller().signIn(email: 'player@example.com', password: 'secret1');

  Future<String> addDeck(AppDatabase target, String name) async {
    final deck = await DeckRepository(target).createDeck(
      gameId: Seed.yugiohId,
      formatId: 'ygo-advanced',
      name: name,
      archetype: name,
    );
    return deck.id;
  }

  /// A backup document holding one deck, as another device would have pushed
  /// it. Built from a throwaway database so it is a real export, not a
  /// hand-written map that could drift from the format.
  Future<Map<String, dynamic>> cloudPayloadWith(String deckName) async {
    final other = createTestDatabase();
    addTearDown(other.close);
    await addDeck(other, deckName);
    return BackupService(other).exportToJson();
  }

  Future<List<String>> localDeckNames() async {
    final decks = await db.select(db.decks).get();
    return [for (final deck in decks) deck.name];
  }

  /// Lets the database's update stream and the debounce timer both run.
  Future<void> settle() => Future<void>.delayed(pushDelay * 4);

  test('the first device to sign in fills an empty cloud', () async {
    await addDeck(db, 'Snake-Eye');

    await signIn();

    expect(backend.pushes, 1);
    expect(backend.storedRevision, 1);
    expect(container.read(syncControllerProvider).dirty, isFalse);
    expect(await localDeckNames(), ['Snake-Eye']);
  });

  test('a device with nothing of its own takes the cloud copy', () async {
    backend.seedCloud(await cloudPayloadWith('Frog Monarch'));

    await signIn();

    expect(
      await localDeckNames(),
      ['Frog Monarch'],
      reason: 'a fresh install signing in should find its data waiting',
    );
    expect(backend.pushes, 0, reason: 'nothing local was worth uploading');
    expect(container.read(syncControllerProvider).conflict, isNull);
  });

  test(
    'local data plus a cloud copy is a conflict, never an overwrite',
    () async {
      await addDeck(db, 'Snake-Eye');
      backend.seedCloud(await cloudPayloadWith('Frog Monarch'));

      await signIn();

      final status = container.read(syncControllerProvider);
      expect(
        status.conflict,
        isNotNull,
        reason: 'two sets of real data must be the user\'s call',
      );
      expect(status.conflict!.remoteDevice, 'iOS');
      expect(
        await localDeckNames(),
        ['Snake-Eye'],
        reason: 'nothing is discarded before the user answers',
      );
      expect(backend.pushes, 0);
    },
  );

  test('keeping this device overwrites the cloud', () async {
    await addDeck(db, 'Snake-Eye');
    backend.seedCloud(await cloudPayloadWith('Frog Monarch'));
    await signIn();

    await controller().resolveKeepLocal();

    final status = container.read(syncControllerProvider);
    expect(status.conflict, isNull);
    expect(status.dirty, isFalse);
    expect(backend.storedRevision, 2);
    expect(await localDeckNames(), ['Snake-Eye']);

    final pushed = backend.storedPayload!['tables'] as Map<String, dynamic>;
    expect((pushed['decks'] as List), hasLength(1));
  });

  test('keeping the cloud copy replaces this device', () async {
    await addDeck(db, 'Snake-Eye');
    backend.seedCloud(await cloudPayloadWith('Frog Monarch'));
    await signIn();

    await controller().resolveKeepCloud();

    expect(await localDeckNames(), ['Frog Monarch']);
    expect(container.read(syncControllerProvider).conflict, isNull);
    expect(container.read(syncControllerProvider).dirty, isFalse);
  });

  test('a pull does not bounce straight back as a push', () async {
    backend.seedCloud(await cloudPayloadWith('Frog Monarch'));

    await signIn();
    await settle();

    expect(
      backend.pushes,
      0,
      reason: 'writing the downloaded snapshot is not a local change',
    );
    expect(container.read(syncControllerProvider).dirty, isFalse);
  });

  test('a change made after a sync is pushed on its own', () async {
    await signIn();
    expect(backend.pushes, 1);

    await addDeck(db, 'Snake-Eye');
    await settle();

    expect(backend.pushes, 2);
    expect(backend.storedRevision, 2);
    expect(container.read(syncControllerProvider).dirty, isFalse);
  });

  test('with automatic sync off a change waits to be sent', () async {
    await signIn();
    await controller().setAutoSync(false);

    await addDeck(db, 'Snake-Eye');
    await settle();

    expect(backend.pushes, 1, reason: 'only the sign-in push happened');
    expect(container.read(syncControllerProvider).dirty, isTrue);

    await controller().syncNow();

    expect(backend.pushes, 2);
  });

  test('a push the server refuses becomes a conflict, not a loss', () async {
    await signIn();
    await addDeck(db, 'Snake-Eye');

    // Another device pushes in the meantime, so this one's expected revision
    // is stale by the time it writes.
    backend.seedCloud(await cloudPayloadWith('Frog Monarch'), revision: 9);

    await controller().syncNow();

    final status = container.read(syncControllerProvider);
    expect(status.conflict?.remoteRevision, 9);
    expect(status.dirty, isTrue, reason: 'the local work is still unsent');
    expect(await localDeckNames(), ['Snake-Eye']);
  });

  test('a failed sync says why and stays dirty', () async {
    await signIn();
    await addDeck(db, 'Snake-Eye');

    backend.nextFailure = SyncException('Network unreachable');
    await controller().syncNow();

    final status = container.read(syncControllerProvider);
    expect(status.error, 'Network unreachable');
    expect(status.dirty, isTrue);
    expect(status.busy, isFalse, reason: 'a failure must not wedge the button');
  });

  test('signing out keeps every deck on the device', () async {
    await addDeck(db, 'Snake-Eye');
    await signIn();

    await controller().signOut();

    final status = container.read(syncControllerProvider);
    expect(status.signedIn, isFalse);
    expect(await localDeckNames(), ['Snake-Eye']);
  });

  test('a second account on the same device starts from zero', () async {
    await addDeck(db, 'Snake-Eye');
    await signIn();
    expect(container.read(syncControllerProvider).baseRevision, 1);

    await controller().signOut();
    await controller().signIn(email: 'other@example.com', password: 'secret1');

    expect(
      container.read(syncControllerProvider).baseRevision,
      isNot(1),
      reason: 'one account\'s revision means nothing to another',
    );
  });
}
