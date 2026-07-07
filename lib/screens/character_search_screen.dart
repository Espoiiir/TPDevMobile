import 'package:flutter/material.dart';

import '../models/rio_character.dart';
import '../services/raider_io_api_service.dart';
import '../widgets/info_chip.dart';
import '../widgets/message_state.dart';
import '../widgets/network_icon_box.dart';
import 'rio_character_detail_screen.dart';

class CharacterSearchScreen extends StatefulWidget {
  const CharacterSearchScreen({super.key});

  @override
  State<CharacterSearchScreen> createState() => _CharacterSearchScreenState();
}

class _CharacterSearchScreenState extends State<CharacterSearchScreen> {
  final RaiderIoApiService _apiService = RaiderIoApiService();
  final TextEditingController _realmController = TextEditingController(
    text: 'Archimonde',
  );
  final TextEditingController _nameController = TextEditingController(
    text: 'Espoiir',
  );

  String _region = 'eu';
  bool _isLoading = false;
  String? _errorMessage;
  RioCharacter? _character;

  @override
  void dispose() {
    _realmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final realm = _realmController.text.trim();
    final name = _nameController.text.trim();

    if (realm.isEmpty || name.isEmpty) {
      setState(() => _errorMessage = 'Renseigne un royaume et un personnage.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final character = await _apiService.fetchCharacter(
        region: _region,
        realm: realm,
        name: name,
      );
      setState(() => _character = character);
    } on RaiderIoApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Erreur inattendue.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche de personnage')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SearchPanel(
            region: _region,
            realmController: _realmController,
            nameController: _nameController,
            isLoading: _isLoading,
            onRegionChanged: (value) => setState(() => _region = value),
            onSearch: _search,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            _ErrorBox(message: _errorMessage!),
          ],
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_character != null)
            _CharacterResultCard(
              character: _character!,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      RioCharacterDetailScreen(character: _character!),
                ),
              ),
            )
          else
            const MessageState(
              icon: Icons.person_search_outlined,
              title: 'Profil Raider.IO',
              message: 'Recherche un personnage par région, royaume et nom.',
            ),
        ],
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.region,
    required this.realmController,
    required this.nameController,
    required this.isLoading,
    required this.onRegionChanged,
    required this.onSearch,
  });

  final String region;
  final TextEditingController realmController;
  final TextEditingController nameController;
  final bool isLoading;
  final ValueChanged<String> onRegionChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 12),
            TextField(
              controller: realmController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Royaume',
                prefixIcon: Icon(Icons.public),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              onSubmitted: (_) => onSearch(),
              decoration: const InputDecoration(
                labelText: 'Personnage',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onSearch,
                icon: const Icon(Icons.search),
                label: const Text('Rechercher'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterResultCard extends StatelessWidget {
  const _CharacterResultCard({required this.character, required this.onTap});

  final RioCharacter character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag:
                    'character-${character.region}-${character.realm}-${character.name}',
                child: NetworkIconBox(url: character.thumbnailUrl, size: 84),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${character.region} - ${character.realm}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        InfoChip(
                          label: 'Classe',
                          value: character.characterClass,
                        ),
                        InfoChip(
                          label: 'Score',
                          value: character.mythicPlusScore.toStringAsFixed(0),
                        ),
                        InfoChip(
                          label: 'Ilvl',
                          value: '${character.itemLevelEquipped}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE57373)),
      ),
      child: Text(message),
    );
  }
}
