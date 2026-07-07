class RioRaidLeaderboardEntry {
  const RioRaidLeaderboardEntry({
    required this.rank,
    required this.regionRank,
    required this.name,
    required this.faction,
    required this.region,
    required this.realm,
    required this.realmSlug,
    required this.logoUrl,
    required this.path,
    required this.encountersDefeated,
  });

  final int rank;
  final int regionRank;
  final String name;
  final String faction;
  final String region;
  final String realm;
  final String realmSlug;
  final String logoUrl;
  final String path;
  final int encountersDefeated;

  factory RioRaidLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    final guild = json['guild'];
    final realm = guild is Map<String, dynamic> ? guild['realm'] : null;
    final region = guild is Map<String, dynamic> ? guild['region'] : null;
    final defeated = json['encountersDefeated'];

    return RioRaidLeaderboardEntry(
      rank: _asInt(json['rank']),
      regionRank: _asInt(json['regionRank']),
      name: guild is Map<String, dynamic> ? _asText(guild['name']) : 'Inconnu',
      faction: guild is Map<String, dynamic>
          ? _asText(guild['faction'])
          : 'Non renseigné',
      region: region is Map<String, dynamic>
          ? _asText(region['slug']).toUpperCase()
          : 'Non renseigné',
      realm: realm is Map<String, dynamic>
          ? _asText(realm['name'])
          : 'Non renseigné',
      realmSlug: realm is Map<String, dynamic>
          ? _asText(realm['slug'])
          : 'non renseigné',
      logoUrl: guild is Map<String, dynamic> ? _asText(guild['logo']) : '',
      path: guild is Map<String, dynamic> ? _asText(guild['path']) : '',
      encountersDefeated: defeated is List ? defeated.length : 0,
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _asText(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? 'Non renseigné' : text;
}
