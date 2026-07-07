class RioGuildRequest {
  const RioGuildRequest({
    required this.region,
    required this.realm,
    required this.name,
  });

  final String region;
  final String realm;
  final String name;
}

class RioGuild {
  const RioGuild({
    required this.name,
    required this.faction,
    required this.region,
    required this.realm,
    required this.profileUrl,
    required this.lastCrawledAt,
    required this.progression,
    required this.rankings,
  });

  final String name;
  final String faction;
  final String region;
  final String realm;
  final String profileUrl;
  final String lastCrawledAt;
  final List<RioRaidProgression> progression;
  final List<RioRaidRanking> rankings;

  factory RioGuild.fromJson(Map<String, dynamic> json) {
    return RioGuild(
      name: _asText(json['name']),
      faction: _asText(json['faction']),
      region: _asText(json['region']).toUpperCase(),
      realm: _asText(json['realm']),
      profileUrl: _asText(json['profile_url']),
      lastCrawledAt: _asText(json['last_crawled_at']),
      progression: _readProgression(json['raid_progression']),
      rankings: _readRankings(json['raid_rankings']),
    );
  }

  RioRaidProgression? get mainProgression {
    if (progression.isEmpty) return null;
    return progression.first;
  }

  RioRaidRanking? get mainRanking {
    if (rankings.isEmpty) return null;
    return rankings.first;
  }
}

class RioRaidProgression {
  const RioRaidProgression({
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

class RioRaidRanking {
  const RioRaidRanking({
    required this.raidSlug,
    required this.world,
    required this.region,
    required this.realm,
  });

  final String raidSlug;
  final int world;
  final int region;
  final int realm;
}

List<RioRaidProgression> _readProgression(dynamic value) {
  if (value is! Map) return const [];

  return value.entries.map((entry) {
    final data = entry.value;
    if (data is! Map) {
      return RioRaidProgression(
        raidSlug: entry.key.toString(),
        summary: 'Non renseigné',
        totalBosses: 0,
        normalKills: 0,
        heroicKills: 0,
        mythicKills: 0,
      );
    }
    return RioRaidProgression(
      raidSlug: entry.key.toString(),
      summary: _asText(data['summary']),
      totalBosses: _asInt(data['total_bosses']),
      normalKills: _asInt(data['normal_bosses_killed']),
      heroicKills: _asInt(data['heroic_bosses_killed']),
      mythicKills: _asInt(data['mythic_bosses_killed']),
    );
  }).toList();
}

List<RioRaidRanking> _readRankings(dynamic value) {
  if (value is! Map) return const [];

  return value.entries.map((entry) {
    final raid = entry.value;
    final mythic = raid is Map ? raid['mythic'] : null;
    return RioRaidRanking(
      raidSlug: entry.key.toString(),
      world: mythic is Map ? _asInt(mythic['world']) : 0,
      region: mythic is Map ? _asInt(mythic['region']) : 0,
      realm: mythic is Map ? _asInt(mythic['realm']) : 0,
    );
  }).toList();
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _asText(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? 'Non renseigné' : text;
}
