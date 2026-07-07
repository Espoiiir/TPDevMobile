import 'package:flutter/material.dart';

import '../models/rio_guild.dart';
import '../services/button_link_raider_io.dart';
import '../widgets/info_chip.dart';

class GuildDetailScreen extends StatelessWidget {
  const GuildDetailScreen({required this.guild, super.key});

  final RioGuild guild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const launcher = ButtonLinkRaiderIo();

    return Scaffold(
      appBar: AppBar(title: Text(guild.name)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: guild.faction.toLowerCase() == 'horde'
                    ? const Color(0xFF8B1E2D)
                    : const Color(0xFF1F5FA8),
                child: const Icon(Icons.shield, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guild.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text('${guild.region} - ${guild.realm}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(label: 'Faction', value: guild.faction),
              InfoChip(label: 'Dernier crawl', value: guild.lastCrawledAt),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                launcher.openExternalUrl(context, guild.profileUrl),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Ouvrir sur Raider.IO'),
          ),
          const SizedBox(height: 22),
          Text(
            'Progression raid',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...guild.progression.map(_ProgressionTile.new),
          const SizedBox(height: 22),
          Text(
            'Classements mythic',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...guild.rankings.map(_RankingTile.new),
          const SizedBox(height: 18),
          SelectableText('Profil Raider.IO: ${guild.profileUrl}'),
        ],
      ),
    );
  }
}

class _ProgressionTile extends StatelessWidget {
  const _ProgressionTile(this.progression);

  final RioRaidProgression progression;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              progression.raidSlug,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoChip(label: 'Résumé', value: progression.summary),
                InfoChip(label: 'Normal', value: '${progression.normalKills}'),
                InfoChip(label: 'Heroic', value: '${progression.heroicKills}'),
                InfoChip(label: 'Mythic', value: '${progression.mythicKills}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile(this.ranking);

  final RioRaidRanking ranking;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(ranking.raidSlug),
        subtitle: Text(
          'World #${ranking.world} | Region #${ranking.region} | Realm #${ranking.realm}',
        ),
        leading: const Icon(Icons.emoji_events_outlined),
      ),
    );
  }
}
