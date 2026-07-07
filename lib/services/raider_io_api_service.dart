import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/rio_character.dart';
import '../models/rio_guild.dart';
import '../models/rio_raid_leaderboard.dart';

class RaiderIoApiException implements Exception {
  const RaiderIoApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RaiderIoApiService {
  RaiderIoApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://raider.io/api/v1';
  final http.Client _client;

  Future<List<RioRaidLeaderboardEntry>> fetchRaidLeaderboard({
    String region = 'world',
    String raid = 'tier-mn-1',
    String difficulty = 'mythic',
    int limit = 10,
  }) async {
    final uri = Uri.parse('$_baseUrl/raiding/raid-rankings').replace(
      queryParameters: {
        'raid': raid,
        'difficulty': difficulty,
        'region': region,
        'page': '0',
      },
    );

    final decoded = await _getObject(uri);
    final rankings = decoded['raidRankings'];
    if (rankings is! List) {
      throw const RaiderIoApiException(
        'Le leaderboard Raider.IO est indisponible.',
      );
    }

    return rankings
        .whereType<Map<String, dynamic>>()
        .take(limit)
        .map(RioRaidLeaderboardEntry.fromJson)
        .toList();
  }

  Future<RioGuild> fetchGuild(RioGuildRequest request) async {
    final uri = Uri.parse('$_baseUrl/guilds/profile').replace(
      queryParameters: {
        'region': request.region,
        'realm': request.realm,
        'name': request.name,
        'fields': 'raid_progression,raid_rankings',
      },
    );

    return RioGuild.fromJson(await _getObject(uri));
  }

  Future<RioCharacter> fetchCharacter({
    required String region,
    required String realm,
    required String name,
  }) async {
    final uri = Uri.parse('$_baseUrl/characters/profile').replace(
      queryParameters: {
        'region': region,
        'realm': realm,
        'name': name,
        'fields':
            'gear,mythic_plus_scores_by_season:current,mythic_plus_best_runs,mythic_plus_ranks,raid_progression,raid_achievement_meta',
      },
    );

    return RioCharacter.fromJson(await _getObject(uri));
  }

  Future<Map<String, dynamic>> _getObject(Uri uri) async {
    try {
      final response = await _client.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw RaiderIoApiException(_readApiError(response.body));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const RaiderIoApiException(
        'Format de réponse Raider.IO inattendu.',
      );
    } on RaiderIoApiException {
      rethrow;
    } on FormatException {
      throw const RaiderIoApiException('La réponse Raider.IO est invalide.');
    } catch (_) {
      throw const RaiderIoApiException(
        'Impossible de contacter l API Raider.IO.',
      );
    }
  }

  String _readApiError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}
    return 'Erreur Raider.IO. Veuillez réessayer.';
  }
}
