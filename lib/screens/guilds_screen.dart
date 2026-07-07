import 'package:flutter/material.dart';

import '../models/rio_guild.dart';
import '../models/rio_raid_leaderboard.dart';
import '../services/raider_io_api_service.dart';
import '../widgets/info_chip.dart';
import '../widgets/network_icon_box.dart';
import 'guild_detail_screen.dart';

class GuildsScreen extends StatefulWidget {
  const GuildsScreen({super.key});

  @override
  State<GuildsScreen> createState() => _GuildsScreenState();
}

class _GuildsScreenState extends State<GuildsScreen> {
  final RaiderIoApiService _apiService = RaiderIoApiService();
  final TextEditingController _realmController = TextEditingController(
    text: 'Hyjal',
  );
  final TextEditingController _nameController = TextEditingController(
    text: 'Lamenters',
  );

  bool _isSearching = false;
  bool _isLoadingLeaderboard = true;
  String? _searchErrorMessage;
  String? _leaderboardErrorMessage;
  String _searchRegion = 'eu';
  String _leaderboardRegion = 'world';
  RioGuild? _searchResult;
  List<RioRaidLeaderboardEntry> _leaderboard = const [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _realmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoadingLeaderboard = true;
      _leaderboardErrorMessage = null;
    });

    try {
      final entries = await _apiService.fetchRaidLeaderboard(
        region: _leaderboardRegion,
        limit: 10,
      );
      setState(() => _leaderboard = entries);
    } on RaiderIoApiException catch (error) {
      setState(() => _leaderboardErrorMessage = error.message);
    } catch (_) {
      setState(() => _leaderboardErrorMessage = 'Leaderboard indisponible.');
    } finally {
      if (mounted) setState(() => _isLoadingLeaderboard = false);
    }
  }

  Future<void> _searchGuild() async {
    final realm = _realmController.text.trim();
    final name = _nameController.text.trim();

    if (realm.isEmpty || name.isEmpty) {
      setState(() {
        _searchErrorMessage = 'Renseigne un royaume et le nom de la guilde.';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchErrorMessage = null;
    });

    try {
      final guild = await _apiService.fetchGuild(
        RioGuildRequest(region: _searchRegion, realm: realm, name: name),
      );
      setState(() => _searchResult = guild);
    } on RaiderIoApiException catch (error) {
      setState(() => _searchErrorMessage = error.message);
    } catch (_) {
      setState(() => _searchErrorMessage = 'Erreur inattendue.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guildes raid'),
        actions: [
          IconButton(
            tooltip: 'Actualiser le leaderboard',
            onPressed: _isLoadingLeaderboard ? null : _loadLeaderboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _GuildSearchPanel(
              region: _searchRegion,
              realmController: _realmController,
              nameController: _nameController,
              isSearching: _isSearching,
              errorMessage: _searchErrorMessage,
              onRegionChanged: (value) {
                setState(() => _searchRegion = value);
              },
              onSearch: _searchGuild,
              onClear: _searchResult == null
                  ? null
                  : () => setState(() => _searchResult = null),
            ),
          ),
          if (_searchResult != null) ...[
            const SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Résultat',
                subtitle: 'Guilde chargée depuis Raider.IO',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: _GuildCard(
                  guild: _searchResult!,
                  onTap: () => _openDetail(_searchResult!),
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: _LeaderboardSection(
              region: _leaderboardRegion,
              entries: _leaderboard,
              isLoading: _isLoadingLeaderboard,
              errorMessage: _leaderboardErrorMessage,
              onRegionChanged: (value) {
                setState(() => _leaderboardRegion = value);
                _loadLeaderboard();
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  void _openDetail(RioGuild guild) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => GuildDetailScreen(guild: guild)));
  }
}

class _GuildSearchPanel extends StatelessWidget {
  const _GuildSearchPanel({
    required this.region,
    required this.realmController,
    required this.nameController,
    required this.isSearching,
    required this.onRegionChanged,
    required this.onSearch,
    required this.onClear,
    this.errorMessage,
  });

  final String region;
  final TextEditingController realmController;
  final TextEditingController nameController;
  final bool isSearching;
  final String? errorMessage;
  final ValueChanged<String> onRegionChanged;
  final VoidCallback onSearch;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: 'Recherche',
              subtitle: 'Région, royaume et nom exact de la guilde',
              dense: true,
            ),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'us', label: Text('US')),
                ButtonSegment(value: 'eu', label: Text('EU')),
                ButtonSegment(value: 'kr', label: Text('KR')),
                ButtonSegment(value: 'tw', label: Text('TW')),
              ],
              selected: {region},
              onSelectionChanged: (selection) =>
                  onRegionChanged(selection.first),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: realmController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Royaume',
                      prefixIcon: Icon(Icons.public),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: nameController,
                    onSubmitted: (_) => onSearch(),
                    decoration: const InputDecoration(
                      labelText: 'Guilde',
                      prefixIcon: Icon(Icons.shield_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFB3261E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isSearching ? null : onSearch,
                    icon: isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(isSearching ? 'Recherche...' : 'Rechercher'),
                  ),
                ),
                if (onClear != null) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Retirer le résultat',
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({
    required this.region,
    required this.entries,
    required this.isLoading,
    required this.onRegionChanged,
    this.errorMessage,
  });

  final String region;
  final List<RioRaidLeaderboardEntry> entries;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onRegionChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: _SectionHeader(
                    title: 'Leaderboard Top 10',
                    subtitle: 'Classement raid mythique Raider.IO',
                    dense: true,
                  ),
                ),
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'world', label: Text('World')),
                    ButtonSegment(value: 'eu', label: Text('EU')),
                    ButtonSegment(value: 'us', label: Text('US')),
                  ],
                  selected: {region},
                  onSelectionChanged: (selection) =>
                      onRegionChanged(selection.first),
                ),
              ],
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(18),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Color(0xFFB3261E)),
                ),
              )
            else
              Column(
                children: entries
                    .map((entry) => _LeaderboardTile(entry, region: region))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile(this.entry, {required this.region});

  final RioRaidLeaderboardEntry entry;
  final String region;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '#${entry.rank}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          NetworkIconBox(url: entry.logoUrl, size: 42),
        ],
      ),
      title: Text(
        entry.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        '${entry.region} - ${entry.realm} | ${entry.encountersDefeated} boss',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        region == 'world' ? 'W#${entry.rank}' : 'R#${entry.regionRank}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.dense = false,
  });

  final String title;
  final String subtitle;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: dense
          ? const EdgeInsets.only(bottom: 10)
          : const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuildCard extends StatelessWidget {
  const _GuildCard({required this.guild, required this.onTap});

  final RioGuild guild;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progression = guild.mainProgression;
    final ranking = guild.mainRanking;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: guild.faction.toLowerCase() == 'horde'
                        ? const Color(0xFF8B1E2D)
                        : const Color(0xFF1F5FA8),
                    child: const Icon(Icons.shield, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guild.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${guild.region} - ${guild.realm}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(label: 'Faction', value: guild.faction),
                  if (progression != null)
                    InfoChip(label: 'Progress', value: progression.summary),
                  if (ranking != null && ranking.world > 0)
                    InfoChip(label: 'World', value: '#${ranking.world}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
