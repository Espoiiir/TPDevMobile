import 'package:flutter/material.dart';

import '../models/rio_character.dart';
import '../widgets/info_chip.dart';
import '../widgets/network_icon_box.dart';

class RioCharacterDetailScreen extends StatelessWidget {
  const RioCharacterDetailScreen({required this.character, super.key});

  final RioCharacter character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(character.name)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Center(
            child: Hero(
              tag:
                  'character-${character.region}-${character.realm}-${character.name}',
              child: NetworkIconBox(url: character.thumbnailUrl, size: 136),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            character.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '${character.region} - ${character.realm}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(label: 'Race', value: character.race),
              InfoChip(label: 'Genre', value: character.gender),
              InfoChip(label: 'Faction', value: character.faction),
              InfoChip(label: 'Classe', value: character.characterClass),
              InfoChip(
                label: 'Spécialisation',
                value: character.activeSpecName,
              ),
              InfoChip(label: 'Rôle', value: character.activeSpecRole),
              InfoChip(
                label: 'Score M+',
                value: character.mythicPlusScore.toStringAsFixed(0),
              ),
              InfoChip(
                label: 'Ilvl équipé',
                value: '${character.itemLevelEquipped}',
              ),
              InfoChip(
                label: 'Ilvl total',
                value: '${character.itemLevelTotal}',
              ),
              InfoChip(
                label: 'Hauts faits',
                value: '${character.achievementPoints}',
              ),
              InfoChip(label: 'Màj', value: character.lastCrawledAt),
            ],
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Scores Mythic+'),
          const SizedBox(height: 10),
          _ScoresPanel(scores: character.mythicPlusScores),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Rangs Raider.IO'),
          const SizedBox(height: 10),
          if (character.mythicPlusRanks.isEmpty)
            const Text('Aucun rang Mythic+ retourné.')
          else
            ...character.mythicPlusRanks.take(6).map(_RankTile.new),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Progression raid'),
          const SizedBox(height: 10),
          if (character.raidProgression.isEmpty)
            const Text('Aucune progression raid retournée.')
          else
            ...character.raidProgression.map(_RaidProgressionTile.new),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Équipement'),
          const SizedBox(height: 10),
          if (character.gearItems.isEmpty)
            const Text('Aucun équipement retourné.')
          else
            _GearGrid(items: character.gearItems),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Meilleures clés'),
          const SizedBox(height: 10),
          if (character.bestRuns.isEmpty)
            const Text('Aucune clé Mythic+ retournée par Raider.IO.')
          else
            ...character.bestRuns.map(_RunTile.new),
          const SizedBox(height: 18),
          SelectableText('Profil Raider.IO: ${character.profileUrl}'),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _ScoresPanel extends StatelessWidget {
  const _ScoresPanel({required this.scores});

  final Map<String, double> scores;

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return const Text('Aucun score détaillé retourné.');
    }

    final visibleScores = scores.entries.where((entry) => entry.value > 0);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: visibleScores
          .map(
            (entry) => InfoChip(
              label: entry.key.replaceAll('_', ' '),
              value: entry.value.toStringAsFixed(1),
            ),
          )
          .toList(),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile(this.rank);

  final RioRankGroup rank;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.leaderboard_outlined),
        title: Text(rank.name),
        subtitle: Text(
          'World #${rank.world} | Region #${rank.region} | Realm #${rank.realm}',
        ),
      ),
    );
  }
}

class _RaidProgressionTile extends StatelessWidget {
  const _RaidProgressionTile(this.progression);

  final RioCharacterRaidProgression progression;

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
                InfoChip(label: 'Resume', value: progression.summary),
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

class _GearGrid extends StatelessWidget {
  const _GearGrid({required this.items});

  final List<RioGearItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 3 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 116,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) => _GearTile(items[index]),
        );
      },
    );
  }
}

class _GearTile extends StatelessWidget {
  const _GearTile(this.item);

  final RioGearItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            NetworkIconBox(url: item.iconUrl, size: 54),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.slot,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'ilvl ${item.itemLevel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.enchants.isNotEmpty || item.gems.isNotEmpty)
                    Text(
                      '${item.enchants.length} enchant | ${item.gems.length} gemme',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunTile extends StatelessWidget {
  const _RunTile(this.run);

  final RioMythicRun run;

  @override
  Widget build(BuildContext context) {
    final time = _formatDuration(run.clearTimeMs);
    final par = _formatDuration(run.parTimeMs);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkIconBox(url: run.iconUrl, size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF2E6F95),
                        child: Text(
                          '+${run.mythicLevel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          run.dungeon,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InfoChip(
                        label: 'Score',
                        value: run.score.toStringAsFixed(1),
                      ),
                      InfoChip(label: 'Temps', value: time),
                      InfoChip(label: 'Timer', value: par),
                      InfoChip(
                        label: 'Upgrades',
                        value: '${run.numKeystoneUpgrades}',
                      ),
                      if (run.specName.isNotEmpty)
                        InfoChip(label: 'Spec', value: run.specName),
                    ],
                  ),
                  if (run.affixes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      run.affixes.join(' | '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(int milliseconds) {
  if (milliseconds <= 0) return 'n/a';
  final duration = Duration(milliseconds: milliseconds);
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
