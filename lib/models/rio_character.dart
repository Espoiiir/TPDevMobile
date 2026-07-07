class RioCharacter {
  const RioCharacter({
    required this.name,
    required this.race,
    required this.characterClass,
    required this.activeSpecName,
    required this.activeSpecRole,
    required this.gender,
    required this.faction,
    required this.region,
    required this.realm,
    required this.profileUrl,
    required this.thumbnailUrl,
    required this.lastCrawledAt,
    required this.achievementPoints,
    required this.itemLevelTotal,
    required this.itemLevelEquipped,
    required this.mythicPlusScore,
    required this.mythicPlusScores,
    required this.mythicPlusRanks,
    required this.raidProgression,
    required this.gearItems,
    required this.bestRuns,
  });

  final String name;
  final String race;
  final String characterClass;
  final String activeSpecName;
  final String activeSpecRole;
  final String gender;
  final String faction;
  final String region;
  final String realm;
  final String profileUrl;
  final String thumbnailUrl;
  final String lastCrawledAt;
  final int achievementPoints;
  final int itemLevelTotal;
  final int itemLevelEquipped;
  final double mythicPlusScore;
  final Map<String, double> mythicPlusScores;
  final List<RioRankGroup> mythicPlusRanks;
  final List<RioCharacterRaidProgression> raidProgression;
  final List<RioGearItem> gearItems;
  final List<RioMythicRun> bestRuns;

  factory RioCharacter.fromJson(Map<String, dynamic> json) {
    final gear = json['gear'];
    final runs = json['mythic_plus_best_runs'];

    return RioCharacter(
      name: _asText(json['name']),
      race: _asText(json['race']),
      characterClass: _asText(json['class']),
      activeSpecName: _asText(json['active_spec_name']),
      activeSpecRole: _asText(json['active_spec_role']),
      gender: _asText(json['gender']),
      faction: _asText(json['faction']),
      region: _asText(json['region']).toUpperCase(),
      realm: _asText(json['realm']),
      profileUrl: _asText(json['profile_url']),
      thumbnailUrl: _asText(json['thumbnail_url']),
      lastCrawledAt: _asText(json['last_crawled_at']),
      achievementPoints: _asInt(json['achievement_points']),
      itemLevelTotal: gear is Map<String, dynamic>
          ? _asInt(gear['item_level_total'])
          : 0,
      itemLevelEquipped: gear is Map<String, dynamic>
          ? _asInt(gear['item_level_equipped'])
          : 0,
      mythicPlusScore: _readCurrentScore(json['mythic_plus_scores_by_season']),
      mythicPlusScores: _readCurrentScores(
        json['mythic_plus_scores_by_season'],
      ),
      mythicPlusRanks: _readRanks(json['mythic_plus_ranks']),
      raidProgression: _readRaidProgression(json['raid_progression']),
      gearItems: gear is Map<String, dynamic>
          ? _readGearItems(gear['items'])
          : const [],
      bestRuns: runs is List
          ? runs
                .whereType<Map<String, dynamic>>()
                .map(RioMythicRun.fromJson)
                .toList()
          : const [],
    );
  }
}

class RioMythicRun {
  const RioMythicRun({
    required this.dungeon,
    required this.shortName,
    required this.mythicLevel,
    required this.numKeystoneUpgrades,
    required this.score,
    required this.completedAt,
    required this.clearTimeMs,
    required this.parTimeMs,
    required this.url,
    required this.specName,
    required this.role,
    required this.iconUrl,
    required this.backgroundImageUrl,
    required this.affixes,
  });

  final String dungeon;
  final String shortName;
  final int mythicLevel;
  final int numKeystoneUpgrades;
  final double score;
  final String completedAt;
  final int clearTimeMs;
  final int parTimeMs;
  final String url;
  final String specName;
  final String role;
  final String iconUrl;
  final String backgroundImageUrl;
  final List<String> affixes;

  factory RioMythicRun.fromJson(Map<String, dynamic> json) {
    final spec = json['spec'];
    final affixes = json['affixes'];

    return RioMythicRun(
      dungeon: _asText(json['dungeon']),
      shortName: _asText(json['short_name']),
      mythicLevel: _asInt(json['mythic_level']),
      numKeystoneUpgrades: _asInt(json['num_keystone_upgrades']),
      score: _asDouble(json['score']),
      completedAt: _asText(json['completed_at']),
      clearTimeMs: _asInt(json['clear_time_ms']),
      parTimeMs: _asInt(json['par_time_ms']),
      url: _asText(json['url']),
      specName: spec is Map<String, dynamic> ? _asText(spec['name']) : '',
      role: _asText(json['role']),
      iconUrl: _asText(json['icon_url']),
      backgroundImageUrl: _asText(json['background_image_url']),
      affixes: affixes is List
          ? affixes
                .whereType<Map<String, dynamic>>()
                .map((affix) => _asText(affix['name']))
                .toList()
          : const [],
    );
  }
}

class RioGearItem {
  const RioGearItem({
    required this.slot,
    required this.name,
    required this.itemLevel,
    required this.iconUrl,
    required this.quality,
    required this.gems,
    required this.enchants,
  });

  final String slot;
  final String name;
  final int itemLevel;
  final String iconUrl;
  final int quality;
  final List<String> gems;
  final List<String> enchants;

  factory RioGearItem.fromEntry(String slot, Map<String, dynamic> json) {
    final icon = _asNullableText(json['icon']);
    return RioGearItem(
      slot: slot,
      name: _asText(json['name']),
      itemLevel: _asInt(json['item_level']),
      iconUrl: icon == null
          ? ''
          : 'https://cdn.raiderio.net/images/wow/icons/large/$icon.jpg',
      quality: _asInt(json['item_quality']),
      gems: _readNamedList(json['gems_detail']),
      enchants: _readNamedList(json['enchants_detail']),
    );
  }
}

class RioRankGroup {
  const RioRankGroup({
    required this.name,
    required this.world,
    required this.region,
    required this.realm,
  });

  final String name;
  final int world;
  final int region;
  final int realm;
}

class RioCharacterRaidProgression {
  const RioCharacterRaidProgression({
    required this.raidSlug,
    required this.summary,
    required this.totalBosses,
    required this.normalKills,
    required this.heroicKills,
    required this.mythicKills,
  });

  final String raidSlug;
  final String summary;
  final int totalBosses;
  final int normalKills;
  final int heroicKills;
  final int mythicKills;
}

double _readCurrentScore(dynamic value) {
  if (value is! List || value.isEmpty) return 0;
  final firstSeason = value.first;
  if (firstSeason is! Map<String, dynamic>) return 0;
  final scores = firstSeason['scores'];
  if (scores is! Map<String, dynamic>) return 0;
  return _asDouble(scores['all']);
}

Map<String, double> _readCurrentScores(dynamic value) {
  if (value is! List || value.isEmpty) return const {};
  final firstSeason = value.first;
  if (firstSeason is! Map<String, dynamic>) return const {};
  final scores = firstSeason['scores'];
  if (scores is! Map) return const {};

  return {
    for (final entry in scores.entries)
      entry.key.toString(): _asDouble(entry.value),
  };
}

List<RioRankGroup> _readRanks(dynamic value) {
  if (value is! Map) return const [];

  return value.entries
      .where((entry) => entry.value is Map)
      .map((entry) {
        final rank = entry.value as Map;
        return RioRankGroup(
          name: entry.key.toString().replaceAll('_', ' '),
          world: _asInt(rank['world']),
          region: _asInt(rank['region']),
          realm: _asInt(rank['realm']),
        );
      })
      .where((rank) => rank.world > 0 || rank.region > 0 || rank.realm > 0)
      .toList();
}

List<RioCharacterRaidProgression> _readRaidProgression(dynamic value) {
  if (value is! Map) return const [];

  return value.entries.map((entry) {
    final data = entry.value;
    if (data is! Map) {
      return RioCharacterRaidProgression(
        raidSlug: entry.key.toString(),
        summary: 'Non renseigne',
        totalBosses: 0,
        normalKills: 0,
        heroicKills: 0,
        mythicKills: 0,
      );
    }
    return RioCharacterRaidProgression(
      raidSlug: entry.key.toString(),
      summary: _asText(data['summary']),
      totalBosses: _asInt(data['total_bosses']),
      normalKills: _asInt(data['normal_bosses_killed']),
      heroicKills: _asInt(data['heroic_bosses_killed']),
      mythicKills: _asInt(data['mythic_bosses_killed']),
    );
  }).toList();
}

List<RioGearItem> _readGearItems(dynamic value) {
  if (value is! Map) return const [];

  return value.entries
      .where((entry) => entry.value is Map<String, dynamic>)
      .map(
        (entry) => RioGearItem.fromEntry(
          entry.key.toString(),
          entry.value as Map<String, dynamic>,
        ),
      )
      .toList();
}

List<String> _readNamedList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map((item) => _asText(item['name']))
      .toList();
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _asText(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? 'Non renseigne' : text;
}

String? _asNullableText(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
