import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final game = provider.gameState;
        if (game == null)
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));

        return Scaffold(
          appBar: AppBar(
            title: Text(game.status.name),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'ACTION', icon: Icon(Icons.flash_on)),
                Tab(text: 'SUSPECTS', icon: Icon(Icons.people)),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildBody(context, game),
              SuspectHandView(game: game),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, GameState game) {
    return Column(
      children: [
        _buildRoleDisplay(game),
        Expanded(
          child: _getPhaseView(game),
        ),
      ],
    );
  }

  Widget _buildRoleDisplay(GameState game) {
    // Determine current player's role (placeholder logic matching first player for now)
    final player = game.players[0]; // In real app, find by client UUID
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.indigo.shade900,
      child: Column(
        children: [
          const Text('YOUR IDENTITY',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text(
            player.role?.name ?? 'UNKNOWN',
            style: const TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _getPhaseView(GameState game) {
    switch (game.status) {
      case GameStatus.CARD_DRAFTING:
        return const DraftingView();
      case GameStatus.CRIME_SELECTION:
        return const CrimeSelectionView();
      case GameStatus.INVESTIGATION:
        return const InvestigationView();
      case GameStatus.WITNESS_IDENTIFICATION:
        return const WitnessIdentificationView();
      case GameStatus.GAME_OVER:
        return const GameOverView();
      default:
        return Center(
            child: Text('Phase: ${game.status.name} under construction'));
    }
  }
}

class DraftingView extends StatefulWidget {
  const DraftingView({super.key});

  @override
  State<DraftingView> createState() => _DraftingViewState();
}

class _DraftingViewState extends State<DraftingView> {
  final Set<String> _selectedMeans = {};
  final Set<String> _selectedClues = {};

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().gameState;
    if (game == null) return const SizedBox.shrink();

    final player = game.players[0]; // Placeholder for self
    final means = player.meansCards ?? [];
    final clues = player.clueCards ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('SELECT 5 MEANS \u0026 5 CLUES',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildSection(
                    'MEANS CARDS', means, _selectedMeans, Colors.red.shade100),
                const SizedBox(height: 16),
                _buildSection(
                    'CLUE CARDS', clues, _selectedClues, Colors.blue.shade100),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, List<String> cards, Set<String> selected, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const Divider(),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cards.map((cardId) {
            final isSelected = selected.contains(cardId);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selected.remove(cardId);
                  } else if (selected.length < 5) {
                    selected.add(cardId);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.indigo : color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.indigo, width: isSelected ? 2 : 1),
                ),
                child: Text(
                  cardId,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final canConfirm = _selectedMeans.length == 5 && _selectedClues.length == 5;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canConfirm
            ? () {
                context.read<GameProvider>().sendAction('confirm_draft', {
                  'selected_means': _selectedMeans.toList(),
                  'selected_clues': _selectedClues.toList(),
                });
              }
            : null,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, foregroundColor: Colors.white),
        child: Text(canConfirm
            ? 'CONFIRM SELECTION'
            : 'SELECT ${5 - _selectedMeans.length} M / ${5 - _selectedClues.length} C'),
      ),
    );
  }
}

class CrimeSelectionView extends StatefulWidget {
  const CrimeSelectionView({super.key});

  @override
  State<CrimeSelectionView> createState() => _CrimeSelectionViewState();
}

class _CrimeSelectionViewState extends State<CrimeSelectionView> {
  String? _selectedMeans;
  String? _selectedClue;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().gameState;
    if (game == null) return const SizedBox.shrink();

    final player = game.players[0]; // Placeholder for self
    if (player.role != Role.MURDERER && player.role != Role.ACCOMPLICE) {
      return const Center(
          child: Text('WAITING FOR MURDERER TO CHOOSE CRIME...'));
    }

    final means = player.meansCards ?? [];
    final clues = player.clueCards ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('CHOOSE THE MURDER WEAPON \u0026 CLUE',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildRadioSection('MEANS', means, _selectedMeans,
                    (val) => setState(() => _selectedMeans = val)),
                const SizedBox(height: 16),
                _buildRadioSection('CLUE', clues, _selectedClue,
                    (val) => setState(() => _selectedClue = val)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildRadioSection(String title, List<String> cards, String? selected,
      Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Divider(),
        Wrap(
          spacing: 8,
          children: cards.map((cardId) {
            final isSelected = selected == cardId;
            return ChoiceChip(
              label: Text(cardId),
              selected: isSelected,
              onSelected: (val) => onSelect(cardId),
              selectedColor: Colors.red.shade200,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final canConfirm = _selectedMeans != null && _selectedClue != null;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canConfirm
            ? () {
                context.read<GameProvider>().sendAction('confirm_crime', {
                  'means_id': _selectedMeans,
                  'clue_id': _selectedClue,
                });
              }
            : null,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, foregroundColor: Colors.white),
        child: const Text('CONFIRM CRIME'),
      ),
    );
  }
}

class InvestigationView extends StatelessWidget {
  const InvestigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().gameState;
    if (game == null) return const SizedBox.shrink();

    // Find Forensic Scientist to get tiles
    final fs =
        game.players.firstWhereOrNull((p) => p.role == Role.FORENSIC_SCIENTIST);
    final tiles = fs?.activeTiles ?? [];

    if (tiles.isEmpty) {
      return const Center(child: Text('FS IS DRAWING TILES...'));
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('SCENE TILES',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, index) {
              return _buildTileCard(context, tiles[index], fs?.isHost ?? false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTileCard(BuildContext context, Tile tile, bool isSelfFS) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              tile.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: tile.options.length,
              itemBuilder: (context, index) {
                final isSelected = tile.selectedOption == index;
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    tile.options[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.indigo : Colors.black54,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          size: 14, color: Colors.indigo)
                      : null,
                  onTap: isSelfFS
                      ? () {
                          context
                              .read<GameProvider>()
                              .sendAction('select_tile_option', {
                            'tile_id': tile.id,
                            'option_index': index,
                          });
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SuspectHandView extends StatelessWidget {
  final GameState game;
  const SuspectHandView({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Only show players who are NOT the Forensic Scientist
    final suspects =
        game.players.where((p) => p.role != Role.FORENSIC_SCIENTIST).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suspects.length,
      itemBuilder: (context, index) {
        final p = suspects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(child: Text(p.name[0])),
            title: Text(p.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${p.meansCards?.length ?? 0} Means | ${p.clueCards?.length ?? 0} Clues'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHandRow(
                        'MEANS', p.meansCards ?? [], Colors.red.shade50),
                    const SizedBox(height: 8),
                    _buildHandRow(
                        'CLUES', p.clueCards ?? [], Colors.blue.shade50),
                    const SizedBox(height: 16),
                    _buildSolveButton(context, p),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandRow(String label, List<String> cards, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: cards
              .map((c) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(4)),
                    child: Text(c, style: const TextStyle(fontSize: 10)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSolveButton(BuildContext context, Player suspect) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.search, size: 16),
        label: const Text('SOLVE AGAINST THIS SUSPECT'),
        onPressed: () => _showSolveDialog(context, suspect),
      ),
    );
  }

  void _showSolveDialog(BuildContext context, Player suspect) {
    showDialog(
      context: context,
      builder: (context) => SolveDialog(suspect: suspect),
    );
  }
}

class SolveDialog extends StatefulWidget {
  final Player suspect;
  const SolveDialog({super.key, required this.suspect});

  @override
  State<SolveDialog> createState() => _SolveDialogState();
}

class _SolveDialogState extends State<SolveDialog> {
  String? _means;
  String? _clue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Accuse ${widget.suspect.name}'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Match their Means and Clue:',
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            _buildPicker('MEANS', widget.suspect.meansCards ?? [], _means,
                (v) => setState(() => _means = v)),
            const SizedBox(height: 16),
            _buildPicker('CLUE', widget.suspect.clueCards ?? [], _clue,
                (v) => setState(() => _clue = v)),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: (_means != null && _clue != null)
              ? () {
                  context.read<GameProvider>().sendAction('solve', {
                    'murderer_id': widget.suspect.id,
                    'means_id': _means,
                    'clue_id': _clue,
                  });
                  Navigator.pop(context);
                }
              : null,
          child: const Text('SOLVE!'),
        ),
      ],
    );
  }

  Widget _buildPicker(String label, List<String> items, String? selected,
      Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 4,
          children: items
              .map((i) => ChoiceChip(
                    label: Text(i, style: const TextStyle(fontSize: 10)),
                    selected: selected == i,
                    onSelected: (v) => onSelect(i),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class WitnessIdentificationView extends StatelessWidget {
  const WitnessIdentificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().gameState;
    if (game == null) return const SizedBox.shrink();

    final player = game.players[0]; // Placeholder for self
    final isMurderer = player.role == Role.MURDERER;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('THE CRIME HAS BEEN SOLVED!',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            isMurderer
                ? 'MURDERER: IDENTIFY THE WITNESS TO ESCAPE!'
                : 'WAITING FOR MURDERER TO IDENTIFY THE WITNESS...',
            textAlign: TextAlign.center,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 24),
          if (isMurderer)
            Expanded(
              child: ListView.builder(
                itemCount: game.players.length,
                itemBuilder: (context, index) {
                  final p = game.players[index];
                  if (p.role == Role.FORENSIC_SCIENTIST ||
                      p.role == Role.MURDERER) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(
                    leading: const Icon(Icons.person_search),
                    title: Text(p.name),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _confirmIdentification(context, p),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _confirmIdentification(BuildContext context, Player target) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Identify ${target.name} as Witness?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              context
                  .read<GameProvider>()
                  .sendAction('identify_witness', {'target_id': target.id});
              Navigator.pop(context);
            },
            child: const Text('YES, THATS THE WITNESS'),
          ),
        ],
      ),
    );
  }
}

class GameOverView extends StatelessWidget {
  const GameOverView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().gameState;
    if (game == null) return const SizedBox.shrink();

    final winner = game.metadata['winner'] ?? 'UNKNOWN';
    final isGoodWin = winner == 'GOOD';

    return Container(
      width: double.infinity,
      color: isGoodWin ? Colors.green.shade900 : Colors.red.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isGoodWin ? Icons.verified_user : Icons.dangerous,
            color: Colors.amber,
            size: 100,
          ),
          const SizedBox(height: 24),
          Text(
            isGoodWin ? 'INVESTIGATORS WIN!' : 'MURDERER ESCAPED!',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          if (game.solutionMeansId != null && game.solutionClueId != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('THE CRIME WAS:',
                      style: TextStyle(color: Colors.white70)),
                  Text('${game.solutionMeansId} with ${game.solutionClueId}',
                      style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              // Action to reset game or return to lobby
              context.read<GameProvider>().sendAction('reset_game', {});
            },
            icon: const Icon(Icons.refresh),
            label: const Text('PLAY AGAIN'),
          ),
        ],
      ),
    );
  }
}
