import 'seed.dart';

/// The starting list of opponent archetypes, one list per format.
///
/// Written by the user from the metagames they actually play against, and kept
/// exactly as they typed it: these names end up in the matchup matrix and in
/// the round editor's menu, so a silent "correction" here would show up as a
/// deck nobody recognises.
///
/// Unlike games and formats, this list is seeded **once** — when the database
/// is created, and once more on the upgrade that introduced it — and never
/// again. A metagame rotates, so a default that could not be deleted for good
/// would be rubbish within a season.
abstract final class ArchetypeSeed {
  /// Format id to the archetypes offered in it.
  static const byFormat = <String, List<String>>{
    'ygo-advanced': _yugiohAdvanced,
    'ygo-edison': _yugiohEdison,
    'mtg-standard': _magicStandard,
    'mtg-modern': _magicModern,
    'mtg-pauper': _magicPauper,
    'mtg-legacy': _magicLegacy,
  };

  /// Which game a seeded format belongs to.
  static String gameOf(String formatId) =>
      formatId.startsWith('ygo-') ? Seed.yugiohId : Seed.magicId;

  /// A stable id, so seeding twice cannot produce the same archetype twice.
  ///
  /// Readable rather than a uuid for the same reason the formats use slugs:
  /// these rows are identical on every device, and an id you can read is an id
  /// you can debug.
  static String idFor(String formatId, String name) =>
      '$formatId/${slugify(name)}';

  static String slugify(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'archetype' : slug;
  }

  static const _yugiohAdvanced = [
    'Snake-Eye Fire King',
    'Ryzeal',
    'Kewl Tune',
    'Mitsurugi',
    'Branded',
    'Invoked',
    'Elfnote',
    'Light and Darkness Ritual',
    'Artmage',
    'Maliss',
    'Fairy Tail',
    'Yummy',
    'Power Patron',
    'Trains',
    'Orcust',
    'Blitzclique',
    'DoomZ',
    'Sky Striker',
  ];

  static const _yugiohEdison = [
    'Frog Monarch',
    'Frog otk',
    'vayu turbo',
    'Blackwing',
    'gigavise',
    'Lightsworn',
    'Gladiator Beast',
    'X-Saber',
  ];

  static const _magicStandard = [
    'Izzet Prowess',
    'Selesnya Ouroboroid',
    'Jeskai Lessons',
    'Izzet Spellementals',
    '4c Control',
    'Mono-Green Landfall',
    'Dimir Excruciator',
    'Izzet Lessons',
    'Izzet Self-Bounce',
    'Sultai Reanimator',
    'Izzet Spells',
    'Azorius Tempo',
    '4c Gearhulk',
    'Lifegain',
    '4c Legends',
    'Mono-Red Aggro',
    'Gruul Delirium',
    'Dimir Midrange',
    'Mono-Black Aggro',
    'Selesnya Landfall',
    'Naya Delirium',
    'Boros Tokens',
    'Izzet Control',
    'Mardu Manufacturing',
    'Dimir Reanimator',
    'Gruul Landfall',
    'Mardu Discard',
    'Mono-Black Midrange',
    'Temur Kona',
  ];

  static const _magicModern = [
    "Goryo's Vengeance",
    'Boros Energy',
    'Esper Blink',
    'Devoted Combo',
    'Dimir Midrange',
    'Affinity',
    'Eldrazi',
    'Living End',
    'Ruby Storm',
    'Izzet Prowess',
    'Mono-Green Eldrazi',
    'Gruul Basking Broodscale',
    'Domain Zoo',
    'Grixis Reanimator',
    'Eldrazi Tron',
    'Neobrand',
    'Amulet Titan',
    'Mono-Blue Belcher',
    'Mono-Red Belcher',
    'Temur Prowess',
    'Azorius Energy',
    'Boros Ponza',
    'Eldrazi Ramp',
    'Jeskai Energy',
    'Azorius Control',
    'Esper Reanimator',
    'Rakdos Burn',
    'Yawgmoth',
    'Grixis Prowess',
    'Izzet Control',
    'Boros Burn',
    'Rakdos HollowOne',
    '4c HollowOne',
    'Dimir Murktide',
    'Grixis Murktide',
    'Mardu Energy',
    'Mono-Black Midrange',
    'Sultai Midrange',
    'Song of Creation',
    'Azorius Blink',
    'Through the Breach',
    'Tron',
    'Esper Energy',
    'Esper Midrange',
    '4/5c Omnath',
    'Selesnya Energy',
    'Mardu Blink',
    'Bant Blink',
    "Death's Shadow",
    'Jeskai Control',
    'Bant Control',
    'Izzet Phoenix',
    'Jund Saga',
    'Simic Midrange',
    'Mono-White Midrange',
  ];

  static const _magicPauper = [
    'Mono Red Madness',
    'Blue Terror',
    'Tron',
    'Grixis Affinity',
    'Elves',
    'Mono Red Rally',
    'Spy Combo',
    'White Aggro',
    'Dimir Faeries',
    'Mono-Blue Faeries',
    'Gruul Ponza',
    'Jeskai Ephemerate',
    'Jund Wildfire',
    'Bogles',
    'Snacker Gates',
    'Rakdos Madness',
    'Golgari Gardens',
    'Ruby Storm',
    'Dredge',
    'Black Sacrifice',
    'Familiars',
    'Inside Out Combo',
    'Azorius Gates',
    'Izzet Terror',
    'Glintblade',
    'Slivers',
    'Burn',
    'Cycle Storm',
    'Turbo Fog',
    'Ephemerate Tron',
    'Kiln Fiend',
    'Gruul Ramp',
    'Food Gardens',
    'Dimir Control',
    'Izzet Faeries',
    'Mono-White Heroic',
    'Walls Combo',
    'Mono-Black Devotion',
    'Storm',
    'Esper Affinity',
    '4c Ephemerate',
    'Mono-Black Aggro',
    'Dimir Terror',
    'Azorius Affinity',
    'Poison Storm',
    'Jeskai Affinity',
    'Dimir Affinity',
    'Grixis Control',
    'Azorius Faeries',
    '5c Ephemerate',
    'Orzhov Ephemerate',
    'Naya Ramp',
    'Sultai Faeries',
    'Temur Ponza',
    'Mardu Ephemerate',
    'Izzet Delver',
    'Bant Control',
    'Bant Ephemerate',
    'Simic Delver',
    'Azorius Ephemerate',
    'Mono-White Ephemerate',
  ];

  static const _magicLegacy = [
    'Doomsday',
    'Dimir Tempo',
    'Blue Artifacts',
    'Rakdos Reanimator',
    'Mono-White Initiative',
    'Sneak and Show',
    'Aluren',
    'Azorius Tempo',
    'Mardu Energy',
    'Boros Energy',
    'Beanstalk Control (No Yorion)',
    'Izzet Delver',
    'Dimir Reanimator',
    'Red Stompy',
    'The EPIC Storm',
    'Lands',
    'Dimir Car',
    'Eldrazi',
    'Jeskai Control',
    'Omni-Tell',
    'Mono-Black Stompy',
    'Death and Taxes (Yorion)',
    'Dimir Control',
    'Boros Initiative',
    'Azorius Control',
    'Ninjas',
    'Oops! All Spells',
    '8-Cast',
    'Stiflenought',
    'Esper Tempo',
    'Sultai Tempo',
    'Mono-Black Midrange',
    'Arclight Phoenix',
    "Death's Shadow",
    'Affinity Stompy',
    'Grixis Tempo',
    'Painter',
    'Temur Delver',
    'Ocelot Pride Tempo',
    'Beanstalk Control (Yorion)',
    'Goblins',
    'Mono-Black Pox',
    'LED Dredge',
    '4C Control',
    'Sultai Depths',
    'Naya Initiative',
    'Merfolk',
    'Jeskai Stoneblade',
    'Sultai Control',
    'Azorius Stoneblade',
    'Bomberman',
  ];
}
