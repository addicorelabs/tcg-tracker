import '../../data/db/seed.dart';
import '../../data/models/enums.dart';
import '../../features/life/domain/life_game.dart';
import '../../l10n/app_localizations.dart';

/// Display names for the seeded catalogue.
///
/// Format names are proper nouns and stay as written, with one exception: the
/// Yu-Gi-Oh! "Avanzato" format is called "Advanced" in English. Anything the
/// user creates is always shown exactly as they typed it.
extension CatalogNames on AppLocalizations {
  static const _advancedFormatId = 'ygo-advanced';

  String gameName(String gameId, String fallback) {
    return switch (gameId) {
      Seed.yugiohId => gameYugioh,
      Seed.magicId => gameMagic,
      _ => fallback,
    };
  }

  String formatName(String formatId, String storedName) {
    return formatId == _advancedFormatId ? formatAdvanced : storedName;
  }

  String eventTypeName(EventType type) {
    return switch (type) {
      EventType.local => eventTypeLocal,
      EventType.online => eventTypeOnline,
      EventType.ots => eventTypeOts,
      EventType.storeChampionship => eventTypeStoreChampionship,
      EventType.showdown => eventTypeShowdown,
      EventType.regional => eventTypeRegional,
      EventType.ptq => eventTypePtq,
      EventType.national => eventTypeNational,
      EventType.continental => eventTypeContinental,
      EventType.worlds => eventTypeWorlds,
    };
  }

  String tournamentStatusName(TournamentStatus status) {
    return switch (status) {
      TournamentStatus.planned => tournamentStatusPlanned,
      TournamentStatus.ongoing => tournamentStatusOngoing,
      TournamentStatus.finished => tournamentStatusFinished,
    };
  }

  String matchResultName(MatchResult result) {
    return switch (result) {
      MatchResult.win => resultWin,
      MatchResult.loss => resultLoss,
      MatchResult.draw => resultDraw,
      MatchResult.bye => resultBye,
    };
  }

  String counterName(CounterKind kind) {
    return switch (kind) {
      CounterKind.poison => counterPoison,
      CounterKind.energy => counterEnergy,
      CounterKind.experience => counterExperience,
      CounterKind.generic => counterGeneric,
    };
  }

  String sectionName(DeckSection section) {
    return switch (section) {
      DeckSection.main => sectionMain,
      DeckSection.side => sectionSide,
      DeckSection.extra => sectionExtra,
      DeckSection.commander => sectionCommander,
    };
  }
}
